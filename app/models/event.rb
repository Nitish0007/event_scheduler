class Event < ApplicationRecord
  belongs_to :user
  has_many :tickets, dependent: :destroy

  accepts_nested_attributes_for :tickets, allow_destroy: true

  validates :event_title, presence: true
  validates :event_date, presence: true
  validates :event_venue, presence: true
  validate :event_date_cannot_be_in_the_past

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
    self.update_columns(tickets_count: tickets_count, updated_at: Time.zone.now) # used update_column to avoid triggering callbacks and validations
  end

  def event_date_cannot_be_in_the_past
    if event_date.present? && event_date < Time.zone.now
      errors.add(:event_date, "can't be in the past")
    end
  end
end