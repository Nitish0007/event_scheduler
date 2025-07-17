class BookingCancellationJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 5

  def perform booking_id
    booking = Booking.find_by_id(booking_id)
    if booking.nil?
      Rails.logger.info "booking not found with booking_id: #{booking_id}"
      raise "Booking not found"
    end

    ticket = booking.ticket
    updated_booked_tickets_count = ticket.booked_ticket_count - booking.quantity
    ticket.update_column(:booked_ticket_count, updated_booked_tickets_count)
  end
end