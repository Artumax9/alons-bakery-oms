class OrderItemBlueprint < Blueprinter::Base
  identifier :id

  field :product_id
  field :product_name do |item|
    item.product.name
  end
  fields :quantity, :unit_price
  field :subtotal do |item|
    item.subtotal
  end
end
