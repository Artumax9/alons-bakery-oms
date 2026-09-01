class OrderBlueprint < Blueprinter::Base
  identifier :id

  fields :status, :delivery_date, :total_price, :discount_amount, :notes
  field :created_at

  view :full do
    association :customer, blueprint: CustomerBlueprint
    association :order_items, blueprint: OrderItemBlueprint
  end
end
