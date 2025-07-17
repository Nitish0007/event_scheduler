class BookingConfirmationJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 5

  def perform customer_id, ticket_id
    user = User.find_by_id(customer_id)
    if user.nil?
      Rails.logger.info "customer not found with customer_id: #{customer_id}"
      raise "Customer not found"
    end

    # Send confirmation email to the user about booking confirmation
    Rails.logger.info "Booking confirmed for user_id: #{user.id}, ticket_id: #{ticket_id}"
    
    # TODO: Add actual email sending logic here
    # Example:
    # BookingMailer.confirmation_email(user, ticket_id).deliver_now
  end
end