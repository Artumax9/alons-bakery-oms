class Product < ApplicationRecord
  has_many :order_items
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :available, -> { where(active: true) }
end
