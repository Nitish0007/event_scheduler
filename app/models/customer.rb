class Customer < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :destroy

  validates :first_name, presence: true
end
