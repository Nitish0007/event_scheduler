class PaymentsController < BaseController
  before_action :authenticate_user!
  before_action :set_booking, only: [:new, :create, :show, :success, :cancel]
  
  def new
    @payment = Payment.new(
      booking_id: @booking.id,
      user_id: current_user.id, 
      amount: @booking.total_amount, 
      currency: 'inr',
      status: :pending,
      payment_method: 0
    )
    @stripe_public_key = ENV['STRIPE_PUBLIC_KEY']
  end
  
  def create
    command = command_klass(:create).new(params, @base_klass, current_user, options)
    @result = command.run
    
    if @result[:success]
      render json: {
        client_secret: @result[:client_secret],
        payment_id: @result[:payment_id]
      }
    else
      render json: { error: @result[:error] }, status: :unprocessable_entity
    end
  rescue BaseCommand::CommandError => e
    handle_error(e)
  rescue => e
    handle_error(e)
  end
  
  def show
    @payment = @booking.payment
    redirect_to new_booking_payment_path(@booking) if @payment.nil?
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
          BookingConfirmationJob.perform_async(@booking.id) if defined?(BookingConfirmationJob)
          
          redirect_to booking_path(@booking), notice: 'Payment successful! Your booking has been confirmed.'
        else
          redirect_to booking_path(@booking), alert: 'Payment is still processing. Please check back later.'
        end
      rescue Stripe::StripeError => e
        redirect_to booking_path(@booking), alert: "Payment verification failed: #{e.message}"
      end
    else
      redirect_to booking_path(@booking), alert: 'Payment not found.'
    end
  end
  
  def cancel
    @payment = @booking.payment
    if @payment&.stripe_payment_intent_id.present?
      begin
        Stripe::PaymentIntent.cancel(@payment.stripe_payment_intent_id)
        @payment.update!(status: :failed)
        @booking.update!(status: :payment_failed)
        
        redirect_to booking_path(@booking), notice: 'Payment was cancelled.'
      rescue Stripe::StripeError => e
        redirect_to booking_path(@booking), alert: "Failed to cancel payment: #{e.message}"
      end
    else
      redirect_to booking_path(@booking), alert: 'No payment to cancel.'
    end
  end
  
  private
  
  def set_booking
    @booking = Booking.find_by(id: params[:booking_id], user_id: current_user.id)
  end
  
  def ensure_booking_owner
    unless @booking.user_id == current_user.id
      redirect_to root_path, alert: 'You are not authorized to access this booking.'
    end
  end
  
  def payment_params
    params.require(:payment).permit(:payment_method)
  end
end 