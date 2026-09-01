class NotifyOrderCreatedJob < ApplicationJob
  queue_as :default

  retry_on Webhooks::Client::DeliveryError, wait: :polynomially_longer, attempts: 5

  def perform(order_id)
    url = ENV["N8N_WEBHOOK_URL"]

    if url.blank?
      Rails.logger.info("[NotifyOrderCreatedJob] N8N_WEBHOOK_URL not set, skipping order #{order_id}")
      return
    end

    order = Order.find(order_id)
    payload = OrderBlueprint.render_as_hash(order, view: :full)

    Webhooks::Client.new(url).post(event: "order.created", order: payload)
  end
end
