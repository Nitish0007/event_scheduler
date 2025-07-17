class Ticket < ApplicationRecord
  belongs_to :event
  has_many :bookings

  validates :ticket_type, presence: true, inclusion: { in: ["basic", "vip"] }

  after_commit :update_total_tickets_count_of_event

  private
  def update_total_tickets_count_of_event
    Event.update_total_tickets_count_for_event event_id
  end
end