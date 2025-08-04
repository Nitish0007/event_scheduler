class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :ticket
  enum status: { pending: 0, confirmed: 1, cancelled: 2, failed: 3 }

  # before_save :check_availability
  # before_save :update_booked_tickets_count
  # before_destroy :update_booked_tickets_count_on_cancel
  # after_commit :send_confirmation_notification


  # def send_confirmation_notification
  #   BookingConfirmationJob.perform_async(user_id, ticket_id)
  # end

  # def check_availability
  #   available_tickets = ticket.tickets_count - ticket.booked_ticket_count

  #   if available_tickets < self.quantity
  #     errors.add(:base, "Not enough tickets available, try with less quantity")
  #     throw(:abort)
  #   end
  # end

  # def update_booked_tickets_count
  #   updated_booked_tickets_count = ticket.booked_ticket_count + self.quantity
  #   ticket.update_column(:booked_ticket_count, updated_booked_tickets_count)
  # end

  # def update_booked_tickets_count_on_cancel
  #   BookingCancellationJob.perform_async(self.id)
  # end

end