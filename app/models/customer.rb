class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, :phone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
end
