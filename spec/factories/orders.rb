FactoryBot.define do
  factory :order do
    customer { nil }
    status { 1 }
    delivery_date { "2026-08-27 16:03:27" }
    total_price { "9.99" }
    notes { "MyText" }
  end
end
