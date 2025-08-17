class ProcessPaymentsInBatchJob
  include Sidekiq::Job
  sidekiq_options queue: "payment_processor", retry: 10

  def perform payment_ids
    payments = Payment.where(id: payment_ids).select(:id, :reference_number)
    payments.each_slice(100) do |payment_batch|
      payment_batch.each do |payment|
        payment_id = payment.id
        reference_number = payment.reference_number
        payment_ref_key = "payment_ref_#{reference_number}"

        # check if payment is already being processed
        if RedisStore.exists?(payment_ref_key)
          next
        end
        RedisStore.set(payment_ref_key, true)
        begin
          Payment.process_payment(payment_id)
        rescue StandardError => e
          Rails.logger.error "Error in process payment job: #{e.message}"
          next
        end
      end
      sleep(0.1)
    end
  end
end