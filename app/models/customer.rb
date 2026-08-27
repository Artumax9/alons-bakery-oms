class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy
  validates :name, :phone, presence: true
end
