class PendingBookingRakeWrapperJob
  include Sidekiq::Job

  def perform
    Event.all.each do |event|
      ProcessPendingBookingsJob.perform_async(event.id)
    end
  end
end