require "rails_helper"

RSpec.describe Order, type: :model do
  it { is_expected.to belong_to(:customer) }
  it { is_expected.to have_many(:order_items).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:delivery_date) }

  it "defines the bakery workflow statuses in order" do
    expect(Order.statuses.keys)
      .to eq(%w[pending confirmed baking ready delivered cancelled])
  end

  it "rejects a negative total_price" do
    expect(build(:order, total_price: -1)).not_to be_valid
  end

  it "destroys its items when destroyed" do
    order = create(:order, :with_items)

    expect { order.destroy }.to change(OrderItem, :count).by(-2)
  end
end
