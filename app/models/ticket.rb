class Ticket < ApplicationRecord
  belongs_to :event
  has_many :bookings

  validates :ticket_type, presence: true, uniqueness: { scope: :event_id, message: "failed to create ticket, ticket type already exists for this event" }
  validates :price_per_ticket, presence: true, numericality: { greater_than: 0 }

  after_commit :update_total_tickets_count_of_event

  before_save :set_available_count

  def event_title
    event.event_title
  end

  private
  def set_available_count
    if self.new_record?
      self.available_count = self.tickets_count
    else
      if self.tickets_count_changed?
        if self.tickets_count.to_i < self.booked_ticket_count.to_i
          errors.add(:tickets_count, "cannot be less than booked ticket count")
          return false
        elsif self.event.event_date < Time.zone.now
          errors.add(:tickets_count, "cannot be updated for past event")
          return false
        end
        self.available_count = self.available_count.to_i + self.tickets_count.to_i
      end
    end
  end

  def update_total_tickets_count_of_event
    Event.update_total_tickets_count_for_event event_id
  end
end