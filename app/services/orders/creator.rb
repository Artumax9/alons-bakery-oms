module Orders
  # The only orchestrator: opens a transaction, builds the lines, reserves
  # stock, computes totals, saves the Order, and enqueues the n8n webhook on
  # success. Returns a ServiceResult wrapping the persisted Order.
  class Creator
    def initialize(params)
      @params = params.to_h.symbolize_keys
    end

    def call
      customer = Customer.find_by(id: @params[:customer_id])
      return ServiceResult.failure("customer not found") if customer.nil?

      line_result = LineBuilder.new(@params[:items]).call
      return line_result if line_result.failure?

      lines = line_result.value
      reservation = nil
      order = nil

      ActiveRecord::Base.transaction do
        reservation = Stock::Reservation.reserve(lines)
        raise ActiveRecord::Rollback if reservation.failure?

        totals = Calculator.new(lines).totals
        order = Order.create!(
          customer: customer,
          delivery_date: @params[:delivery_date],
          notes: @params[:notes],
          status: :pending,
          total_price: totals.total,
          discount_amount: totals.discount,
          order_items: lines
        )
      end

      return reservation if reservation&.failure?
      return ServiceResult.failure("order could not be created") unless order&.persisted?

      NotifyOrderCreatedJob.perform_later(order.id)
      ServiceResult.success(order)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.failure(e.record.errors.full_messages)
    end
  end
end
