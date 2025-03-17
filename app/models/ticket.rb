class Ticket < ApplicationRecord
  belongs_to :event
  has_many :bookings

  before_save :update_total_tickets_count_of_event

  private
  def update_total_tickets_count_of_event
    Event.update_total_tickets_count_for_event event_id
  end
end