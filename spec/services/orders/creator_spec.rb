require "rails_helper"

RSpec.describe Orders::Creator do
  let(:customer) { create(:customer) }
  let(:rolls) { create(:product, price: 1500, stock: 20) }
  let(:bread) { create(:product, price: 1000, stock: 20) }

  def params(items:)
    { customer_id: customer.id, delivery_date: 2.days.from_now, items: items }
  end

  it "creates an order, freezes prices and applies the dozen discount" do
    result = described_class.new(
      params(items: [ { product_id: rolls.id, quantity: 12 },
                      { product_id: bread.id, quantity: 2 } ])
    ).call

    expect(result).to be_success
    order = result.value
    expect(order).to be_persisted
    expect(order).to be_pending
    expect(order.order_items.size).to eq(2)
    expect(order.discount_amount).to eq(1500)
    expect(order.total_price).to eq(18500) # 20000 - 1500
  end

  it "uses the database price, not a price sent by the client" do
    result = described_class.new(
      params(items: [ { product_id: rolls.id, quantity: 1, unit_price: 1 } ])
    ).call

    expect(result.value.order_items.first.unit_price).to eq(1500)
  end

  it "decrements product stock" do
    described_class.new(params(items: [ { product_id: rolls.id, quantity: 5 } ])).call

    expect(rolls.reload.stock).to eq(15)
  end

  it "enqueues the n8n notification" do
    expect {
      described_class.new(params(items: [ { product_id: rolls.id, quantity: 1 } ])).call
    }.to have_enqueued_job(NotifyOrderCreatedJob)
  end

  it "fails and rolls back everything when stock is insufficient" do
    result = described_class.new(params(items: [ { product_id: rolls.id, quantity: 999 } ])).call

    expect(result).to be_failure
    expect(result.errors.first).to match(/insufficient stock/)
    expect(Order.count).to eq(0)
    expect(rolls.reload.stock).to eq(20)
  end

  it "fails when a product does not exist" do
    result = described_class.new(params(items: [ { product_id: -1, quantity: 1 } ])).call

    expect(result).to be_failure
    expect(Order.count).to eq(0)
  end

  it "fails when the customer does not exist" do
    result = described_class.new(
      { customer_id: -1, delivery_date: 2.days.from_now, items: [ { product_id: rolls.id, quantity: 1 } ] }
    ).call

    expect(result).to be_failure
    expect(result.errors).to include("customer not found")
  end
end
