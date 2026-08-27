require 'rails_helper'

RSpec.describe Product, type: :model do
  it "It is valid if the price is greater than zero " do
    product = build(:product, price: 1500.50)
    expect(product).to be_valid
  end

  it "It is invalid if the price is zero or negative" do
    product = build(:product, price: 0)
    expect(product).not_to be_valid

    product.price = -100
    expect(product).not_to be_valid
  end
end
