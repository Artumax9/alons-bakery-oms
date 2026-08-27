class Order < ApplicationRecord
  belongs_to :customer
  has_many :orders_items, dependent: :destroy

  enum status: { pending: 0, baking: 1, ready: 2, delivered: 3, cancelled: 4 }
  validates :delivery_date, presence: true
end
