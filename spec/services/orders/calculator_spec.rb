require "rails_helper"

RSpec.describe Orders::Calculator do
  it "sums line subtotals and applies the per-line dozen discount" do
    rolls = build(:order_item, quantity: 12, unit_price: 1500)   # 18000 - 1500 discount
    bread = build(:order_item, quantity: 2, unit_price: 1000)    # 2000, no discount

    totals = described_class.new([ rolls, bread ]).totals

    expect(totals.subtotal).to eq(20000)
    expect(totals.discount).to eq(1500)
    expect(totals.total).to eq(18500)
  end

  it "returns zeros for an empty order" do
    totals = described_class.new([]).totals

    expect(totals.subtotal).to eq(0)
    expect(totals.discount).to eq(0)
    expect(totals.total).to eq(0)
  end
end
