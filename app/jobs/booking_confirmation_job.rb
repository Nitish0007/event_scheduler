class BookingConfirmationJob
  include Sidekiq::Job

  def perform customer_id, ticket_id
    user = Customer_find_by_id(customer_id)&.user
    
    # use user's email address
    # Send confirmation email to the user about booking confirmation
    Rails.logger.info "Booking confirmed for user_id: #{user_id}, ticket_id: #{ticket_id}"

  end
end