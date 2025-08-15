class ProcessPaymentJob
  include Sidekiq::Job
  sidekiq_options queue: "process_payments", retry: 5

  def perform(payment_id)
    payment = Payment.find_by_id(payment_id)

    # check available tickets to avoid overbooking
    available_tickets_count = Rails.cache.fetch("available_tickets_#{payment.booking.ticket.event_id}_#{payment.booking.ticket_type}", expires_in: 24.hours) do
      payment.booking.ticket.available_count
    end

    if available_tickets_count < payment.booking.quantity
      payment.update!(status: :failed)
      return
    end

    # create stripe payment intent
    payment_intent = Payment.create_stripe_payment_intent(payment)
    payment.update!(stripe_payment_intent_id: payment_intent.id)

    # update booking status to payment_pending
    payment.booking.update!(status: :payment_pending)
  rescue StandardError => e
    Rails.logger.error "Error in process payment job: #{e.message}"
    raise e
  end
end