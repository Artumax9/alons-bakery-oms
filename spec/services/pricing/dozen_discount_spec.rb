require "rails_helper"

RSpec.describe Pricing::DozenDiscount do
  def discount(quantity, unit_price)
    described_class.new(quantity: quantity, unit_price: unit_price).amount
  end

  it "gives one free unit per complete dozen" do
    # 12 cinnamon rolls at 1500 => one unit free
    expect(discount(12, 1500)).to eq(1500)
  end

  it "does not discount an incomplete dozen" do
    expect(discount(11, 1500)).to eq(0)
  end

  it "stacks one free unit for every complete dozen" do
    expect(discount(24, 1500)).to eq(3000)
    expect(discount(25, 1500)).to eq(3000)
  end

  it "returns zero for non-positive quantities" do
    expect(discount(0, 1500)).to eq(0)
    expect(discount(-5, 1500)).to eq(0)
  end

  it "returns zero when the unit price is not positive" do
    expect(discount(12, 0)).to eq(0)
  end

  it "rounds to cents" do
    expect(discount(12, 10.999)).to eq(11.0)
  end
end
