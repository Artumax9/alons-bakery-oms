require "rails_helper"

RSpec.describe Orders::StatusTransition do
  it "allows a valid forward transition" do
    order = create(:order, status: :pending)

    result = described_class.new(order, :confirmed).call

    expect(result).to be_success
    expect(order.reload).to be_confirmed
  end

  it "rejects a transition that is not allowed from the current state" do
    order = create(:order, status: :pending)

    result = described_class.new(order, :delivered).call

    expect(result).to be_failure
    expect(result.errors.first).to match(/cannot move order from pending to delivered/)
    expect(order.reload).to be_pending
  end

  it "rejects an unknown status" do
    order = create(:order, status: :pending)

    expect(described_class.new(order, :frozen).call).to be_failure
  end

  it "restores stock when an order is cancelled" do
    order = create(:order, :with_items, status: :confirmed)
    item = order.order_items.first
    stock_before = item.product.stock

    described_class.new(order, :cancelled).call

    expect(order.reload).to be_cancelled
    expect(item.product.reload.stock).to eq(stock_before + item.quantity)
  end
end
