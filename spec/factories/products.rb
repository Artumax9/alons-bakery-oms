FactoryBot.define do
  factory :product do
    name { "#{Faker::Dessert.variety} #{Faker::Number.unique.number(digits: 4)}" }
    description { Faker::Food.description }
    price { 1500.00 }
    active { true }
    stock { 50 }
    labor_percentage { 0 }

    trait :out_of_stock do
      stock { 0 }
    end

    trait :inactive do
      active { false }
    end
  end
end
