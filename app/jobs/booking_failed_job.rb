class BookingFailedJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 5

  def perform booking_ids
    bookings = Booking.where(id: booking_ids).includes(:user, :ticket)
    bookings.each do |booking|
      user = booking.user
      ticket = booking.ticket
      BookingMailer.failed_email(user, booking, ticket).deliver_now
      Rails.logger.info "Email sent for booking failed for user_id: #{user.id}, ticket_id: #{ticket.id}, booking_id: #{booking.id}"
    end
  end
end