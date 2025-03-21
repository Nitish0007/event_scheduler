class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable#, :confirmable

  enum role: { customer: 0, organizer: 1}

  validates :role, presence: true, inclusion: { in: roles.keys }

  has_one :organizer
  has_one :customer
end
