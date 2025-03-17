class Organizer < ApplicationRecord
  belongs_to :user
  has_many :events, dependent: :destroy

  validates :first_name, presence: true
  
end
