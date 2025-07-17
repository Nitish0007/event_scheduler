class Event < ApplicationRecord
  belongs_to :user
  has_many :tickets, dependent: :destroy

  accepts_nested_attributes_for :tickets, allow_destroy: true

  after_update :notify_customer_on_update

  def notify_customer_on_update
    EventUpdationJob.perform_async(self.id)
  end

  def self.update_total_tickets_count_for_event event_id
    event = Event.find_by(id: event_id)
    if event.present?
      event.update_total_tickets_count_for_event
    end
  end

  def update_total_tickets_count_for_event
    tickets_count = tickets.sum(&:tickets_count)
    self.update_column(:tickets_count, tickets_count) # used update_column to avoid triggering callbacks and validations
  end
end