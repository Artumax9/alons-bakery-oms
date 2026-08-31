class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Line total before any discount.
  def subtotal
    unit_price * quantity
  end
end
