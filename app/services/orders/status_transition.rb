module Orders
  # Explicit state machine. Kept as ~20 lines of plain Ruby instead of a gem so
  # it's yours to read and explain.
  class StatusTransition
    TRANSITIONS = {
      "pending" => %w[confirmed cancelled],
      "confirmed" => %w[baking cancelled],
      "baking" => %w[ready],
      "ready" => %w[delivered],
      "delivered" => [],
      "cancelled" => []
    }.freeze

    def initialize(order, target_status)
      @order = order
      @target = target_status.to_s
    end

    def call
      return ServiceResult.failure("unknown status #{@target.inspect}") unless Order.statuses.key?(@target)

      allowed = TRANSITIONS.fetch(@order.status, [])
      unless allowed.include?(@target)
        return ServiceResult.failure("cannot move order from #{@order.status} to #{@target}")
      end

      ActiveRecord::Base.transaction do
        Stock::Reservation.release(@order.order_items) if @target == "cancelled"
        @order.update!(status: @target)
      end

      ServiceResult.success(@order)
    rescue ActiveRecord::RecordInvalid => e
      ServiceResult.failure(e.record.errors.full_messages)
    end
  end
end
