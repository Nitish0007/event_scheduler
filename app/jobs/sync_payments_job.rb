class SyncPaymentsJob
  include Sidekiq::Job
  sidekiq_options queue: "sync_payments", retry: 5

  def perform(payment_ids)
    Payment.where(id: payment_ids).each do |payment|
      payment.sync_with_stripe
    end
  end
end