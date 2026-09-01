require "rails_helper"

RSpec.describe Stock::Reservation do
  let(:product) { create(:product, stock: 10) }

  describe ".reserve" do
    it "decrements stock and succeeds when there is enough" do
      line = build(:order_item, product: product, quantity: 4)

      result = ActiveRecord::Base.transaction { described_class.reserve([ line ]) }

      expect(result).to be_success
      expect(product.reload.stock).to eq(6)
    end

    it "sums quantities across lines of the same product" do
      lines = [ build(:order_item, product: product, quantity: 3),
                build(:order_item, product: product, quantity: 3) ]

      ActiveRecord::Base.transaction { described_class.reserve(lines) }

      expect(product.reload.stock).to eq(4)
    end

    it "fails without touching stock when there is not enough" do
      line = build(:order_item, product: product, quantity: 11)

      result = ActiveRecord::Base.transaction { described_class.reserve([ line ]) }

      expect(result).to be_failure
      expect(result.errors.first).to match(/insufficient stock/)
      expect(product.reload.stock).to eq(10)
    end
  end

  describe ".release" do
    it "restores stock" do
      line = build(:order_item, product: product, quantity: 4)

      ActiveRecord::Base.transaction { described_class.release([ line ]) }

      expect(product.reload.stock).to eq(14)
    end
  end
end
