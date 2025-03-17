class Event < ApplicationRecord
  belongs_to :organizer
  has_many :tickets, dependent: :destroy

  accepts_nested_attributes_for :tickets, allow_destroy: true

  after_update :notify_customer_on_update

  def notify_customer_on_update
    EventUpdationJob.perform_in(1.minute, self.id)
  end

  def self.update_total_tickets_count_for_event event_id
    Event.find_by(id: event_id).update_total_tickets_count_for_event
  end

  def update_total_tickets_count_for_event
    tickets_count = tickets.sum(&:tickets_count)
    self.update_column(:tickets_count, tickets_count) # used update_column to avoid triggering callbacks and validations
  end
end