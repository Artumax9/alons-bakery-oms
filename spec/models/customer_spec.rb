require 'rails_helper'

RSpec.describe Customer, type: :model do
  it "It is valid with the correct attributes" do
    customer = build(:customer)
    expect(customer).to be_valid
  end

  it "It is invalid without a name" do
    customer = build(:customer, name: nil)
    expect(customer).not_to be_valid
  end

  it "It is invalid without a phone number." do
    customer = build(:customer, phone: nil)
    expect(customer).not_to be_valid
  end
end
