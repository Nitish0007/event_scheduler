class ProcessPaymentJob
  include Sidekiq::Job
  sidekiq_options queue: "payment_processor", retry: 5

  def perform(payment_id)
    begin
      Payment.process_payment(payment_id)
    rescue StandardError => e
      Rails.logger.error "Error in process payment job: #{e.message}"
      raise e
    end
  end

end