namespace :bookings do

  desc "Process pending bookings and mark them as confirmed or failed"
  task process_pending_bookings: :environment do
    puts "Starting booking confirmation process at #{Time.current}"
    Event.all.each do |e|
      ProcessPendingBookingsJob.perform_async(e.id)
    end
  end
  
end
