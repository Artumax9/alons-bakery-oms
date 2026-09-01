class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Rails 8 requires the attribute name as the first positional argument.
  # Stored as an integer column; gives us `order.pending?`, `order.confirmed!`,
  # and the `Order.ready` scope for free.
  enum :status, {
    pending: 0,
    confirmed: 1,
    baking: 2,
    ready: 3,
    delivered: 4,
    cancelled: 5
  }

  # prefix: :payment gives `order.payment_transfer?` / `Order.payment_qr`
  # without colliding with the status methods.
  enum :payment_method, {
    cash: 0,
    transfer: 1,
    qr: 2,
    mercado_pago: 3
  }, prefix: :payment

  validates :delivery_date, presence: true
  validates :total_price, :discount_amount,
            numericality: { greater_than_or_equal_to: 0 }
end
