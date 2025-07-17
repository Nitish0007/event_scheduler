class EventUpdationJob
  include Sidekiq::Job
  sidekiq_options queue: "default", retry: 5

  def perform event_id
    Rails.logger.info "event udpated"
    event = Event.find_by_id(event_id)
    if event.nil?
      Rails.logger.info "event not found"
      raise "Event not found"
    end

    ticket_ids = event.tickets.pluck(:id)
    customer_ids = Booking.where(ticket_id: ticket_ids).pluck(:customer_id)

    customer_ids.each do |customer_id|
      user = Customer.find_by_id(customer_id)&.user
      if user.nil?
        Rails.logger.info "customer not found with customer_id: #{customer_id}"
        raise "Customer not found"
      else
        # send mail to all customers who have booked for this event
        Rails.logger.info "Hey your event is updated, please check on the dashboard what's new"
      end
    end
  end
end