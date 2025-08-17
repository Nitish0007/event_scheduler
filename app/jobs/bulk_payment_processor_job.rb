class BulkPaymentProcessorJob
  include Sidekiq::Job
  sidekiq_options queue: "bulk_payment_processor", retry: 5

  def perform
    # process payments that are still in processing status but have not been updated in 24 hours
    Payment.where(status: :processing, updated_at: ..20.hours.ago).select(:id, :stripe_payment_intent_id).find_in_batches(batch_size: 1000) do |batch|
      SyncPaymentsJob.perform_async(batch.pluck(:id))
    end

    # process payments that are still in processing status    
    Payment.where(status: :processing, updated_at: 20.hours.ago..).select(:id).find_in_batches(batch_size: 1000) do |batch|
      payment_ids = batch.pluck(:id)
      ProcessPaymentsInBatchJob.perform_async(payment_ids)
    end
  rescue StandardError => e
    Rails.logger.error "Error in BulkPaymentProcessorJob: #{e.message}"
    raise e
  end
end