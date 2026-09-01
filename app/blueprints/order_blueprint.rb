class OrderBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :payment_method, :delivery_date, :total_price, :discount_amount, :notes
  field :created_at
  field :customer_name do |order|
    order.customer.name
  end

  view :full do
    association :customer, blueprint: CustomerBlueprint
    association :order_items, blueprint: OrderItemBlueprint
  end
end
