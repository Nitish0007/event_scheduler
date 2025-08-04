namespace :bookings do
  # NOTE: this rake task is not in use currently because using PendingBookingRakeWrapperJob via sidekiq-cron
  desc "Process pending bookings and mark them as confirmed or failed"
  task process_pending_bookings: :environment do
    puts "Starting booking confirmation process at #{Time.current}"
    PendingBookingRakeWrapperJob.perform_async
  end
  
end
