class Api::V1::PaymentsController < Api::V1::BaseController
  before_action :ensure_configured
  before_action :set_booking, only: [:show, :update, :success, :cancel]

  def show
    @payment = Payment.find_by(id: params[:id], user_id: current_user.id)
    
    if @payment
      render json: {
        data: PaymentSerializer.new(@payment).as_json,
        stripe_public_key: Rails.configuration.stripe[:publishable_key]
      }, status: :ok
    else
      render_error("Payment not found", :not_found)
    end
  end

  def update
    command = Payment::Update.new(params, Payment, current_user, {})
    @result = command.run

    Rails.logger.info ">>>>>>>>>>>>> Result: #{@result.inspect}"

    if @result[:success]
      render json: { 
        data: @result,
        message: @result[:message]
      }, status: :ok
    else
      render json: { 
        error: @result[:message] 
      }, status: :unprocessable_entity
    end
  rescue BaseCommand::CommandError => e
    render_error(e.message, e.status_code || :unprocessable_entity)
  rescue => e
    Rails.logger.error("Payment update error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render_error("Failed to update payment", :internal_server_error)
  end

  def success
    @payment = @booking.payment
    
    if @payment&.stripe_payment_intent_id.present?
      begin
        payment_intent = Stripe::PaymentIntent.retrieve(@payment.stripe_payment_intent_id)
        
        if payment_intent.status == 'succeeded'
          @payment.update!(status: :completed)
          @booking.update!(status: :confirmed)
          
          # Send confirmation email
          # BookingConfirmationJob.perform_async(@booking.id) if defined?(BookingConfirmationJob)
          
          render json: { 
            message: 'Payment successful! Your booking has been confirmed.',
            payment_status: 'completed',
            booking_status: 'confirmed'
          }, status: :ok
        else
          render json: { 
            message: 'Payment is still processing. Please check back later.',
            payment_status: payment_intent.status
          }, status: :ok
        end
      rescue Stripe::StripeError => e
        render_error("Payment verification failed: #{e.message}", :unprocessable_entity)
      end
    else
      render_error("Payment not found", :not_found)
    end
  end

  def cancel
    @payment = @booking.payment
    
    if @payment&.stripe_payment_intent_id.present?
      begin
        Stripe::PaymentIntent.cancel(@payment.stripe_payment_intent_id)
        @payment.update!(status: :failed)
        @booking.update!(status: :payment_failed)
        
        render json: { 
          message: 'Payment was cancelled.',
          payment_status: 'failed',
          booking_status: 'payment_failed'
        }, status: :ok
      rescue Stripe::StripeError => e
        render_error("Failed to cancel payment: #{e.message}", :unprocessable_entity)
      end
    else
      render_error("No payment to cancel", :not_found)
    end
  end

  private

  def set_booking
    @booking = Booking.find_by(id: params[:booking_id], user_id: current_user.id)
    
    unless @booking
      render_error("Booking not found", :not_found)
      return
    end
  end

  def ensure_configured
    StripeConfig.ensure_configured!
  end
end
