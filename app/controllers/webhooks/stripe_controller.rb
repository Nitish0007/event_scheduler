class Webhooks::StripeController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_request!
  before_action :verify_stripe_signature
  
  def create
    # Ensure webhook secret is configured
    unless ENV['STRIPE_WEBHOOK_SECRET'].present?
      Rails.logger.error "STRIPE_WEBHOOK_SECRET is not configured"
      return head :internal_server_error
    end

    event = Stripe::Webhook.construct_event(
      request.body.read,
      request.headers['Stripe-Signature'],
      ENV['STRIPE_WEBHOOK_SECRET']
    )
    
    case event.type
    when 'payment_intent.succeeded'
      handle_payment_success(event.data.object)
    when 'payment_intent.payment_failed'
      handle_payment_failure(event.data.object)
    when 'payment_intent.canceled'
      handle_payment_cancellation(event.data.object)
    end
    
    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Webhook JSON parsing error: #{e.message}"
    head :bad_request
  rescue Stripe::SignatureVerificationError => e
    Rails.logger.error "Webhook signature verification failed: #{e.message}"
    head :bad_request
  end
  
  private
  
  def handle_payment_success(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment
    
    payment.update!(
      status: :completed,
      fee: payment_intent.application_fee_amount ? payment_intent.application_fee_amount / 100.0 : 0
    )
    
    booking = payment.booking
    booking.update!(status: :payment_completed)
    
    # Send confirmation email
    # BookingConfirmationJob.perform_async(booking.id) if defined?(BookingConfirmationJob)
  end
  
  def handle_payment_failure(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment
    
    payment.update!(status: :failed)
    payment.booking.update!(status: :payment_failed)
    
    # Send failure notification
    # BookingFailedJob.perform_async(payment.booking.id) if defined?(BookingFailedJob)
  end
  
  def handle_payment_cancellation(payment_intent)
    payment = Payment.find_by(stripe_payment_intent_id: payment_intent.id)
    return unless payment
    
    payment.update!(status: :cancelled)
    payment.booking.update!(status: :cancelled)
  end
  
  def verify_stripe_signature
    # This method verifies that the webhook came from Stripe
    # The actual verification is done in the create method
  end
end 