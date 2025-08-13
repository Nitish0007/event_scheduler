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

  def process_pending_bookings
    pending_bookings = Booking.includes(:ticket).where(status: "payment_completed", ticket: { event_id: self.id })
    booking_ids_to_be_confirmed = []
    booking_ids_to_be_failed = []
    available_count_for_each_type_of_ticket = Hash.new(0)
    booked_count_for_each_type_of_ticket = Hash.new(0)
    tkts = self.tickets
    tkts.each do |ticket|
      available_count_for_each_type_of_ticket[ticket.ticket_type] = ticket.available_count
      booked_count_for_each_type_of_ticket[ticket.ticket_type] = ticket.booked_ticket_count
    end

    pending_bookings.find_each(batch_size: 500) do |booking|
      if Time.zone.now < self.event_date && available_count_for_each_type_of_ticket[booking.ticket.ticket_type] >= booking.quantity
        booking_ids_to_be_confirmed << booking.id
        available_count_for_each_type_of_ticket[booking.ticket.ticket_type] -= booking.quantity
        booking.total_amount = booking.quantity * booking.ticket.price_per_ticket
        booked_count_for_each_type_of_ticket[booking.ticket.ticket_type] += booking.quantity
      else
        booking_ids_to_be_failed << booking.id
      end
    end

    # TODO: can update without triggering callbacks and validations
    pending_bookings.map(&:save)
    
    ActiveRecord::Base.transaction do
      # update status of bookings to be confirmed and cancelled and available count for each type of ticket
      Booking.where(id: booking_ids_to_be_confirmed).update_all(status: "confirmed") if booking_ids_to_be_confirmed.present?
      Booking.where(id: booking_ids_to_be_failed).update_all(status: "failed") if booking_ids_to_be_failed.present?
      # update available count and booked count for each type of ticket
      tkts.each do |ticket|
        ticket.update_column(:available_count, available_count_for_each_type_of_ticket[ticket.ticket_type])
        ticket.update_column(:booked_ticket_count, booked_count_for_each_type_of_ticket[ticket.ticket_type])
      end

      # send confirmation and failed statuses emails to users
      BookingConfirmationJob.perform_async(booking_ids_to_be_confirmed) if booking_ids_to_be_confirmed.present?
      BookingFailedJob.perform_async(booking_ids_to_be_failed) if booking_ids_to_be_failed.present?
    rescue => e
      Rails.logger.error "Error in process_pending_bookings for event_id: #{self.id} and event_date: #{self.event_date}: #{e.message}"
      raise e
    end
  end
end