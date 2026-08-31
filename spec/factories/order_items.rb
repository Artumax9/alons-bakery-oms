FactoryBot.define do
  factory :order_item do
    association :order
    association :product
    quantity { 3 }
    unit_price { product.price }
  end
end
