FactoryBot.define do
  factory :product do
    name { "Cinnamon Roll #{Faker::Dessert.flavor}" }
    description { Faker::Food.description }
    price { "1500.00" }
    active { true }
  end
end
