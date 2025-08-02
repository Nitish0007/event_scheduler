class ProcessPendingBookingsJob
  include Sidekiq::Job
  sidekiq_options queue: "process_pending_bookings", retry: 10

  def perform event_id
    event = Event.find_by_id(event_id)
    if event.nil?
      Rails.logger.info "event not found with event_id: #{event_id}"
      raise "Event not found with event_id: #{event_id}"
    end

    begin
      event.process_pending_bookings
    rescue => e
      Rails.logger.error "Error in process_pending_bookings_job: #{e.message}"
      raise e
    end
  end
end