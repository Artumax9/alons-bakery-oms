require "rails_helper"

RSpec.describe OrderItem, type: :model do
  it { is_expected.to belong_to(:order) }
  it { is_expected.to belong_to(:product) }
  it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }

  it "computes its subtotal as unit_price * quantity" do
    item = build(:order_item, quantity: 3, unit_price: 1200)

    expect(item.subtotal).to eq(3600)
  end
end
