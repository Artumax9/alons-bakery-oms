FactoryBot.define do
  factory :order do
    association :customer
    status { :pending }
    delivery_date { 2.days.from_now }
    total_price { 0 }
    discount_amount { 0 }
    notes { nil }

    trait :with_items do
      transient do
        items_count { 2 }
      end

      after(:create) do |order, evaluator|
        create_list(:order_item, evaluator.items_count, order: order)
        totals = Orders::Calculator.new(order.order_items.reload).totals
        order.update!(total_price: totals.total, discount_amount: totals.discount)
      end
    end
  end
end
