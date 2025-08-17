class PaymentsController < BaseController
  # skip_before_action :authenticate_user!
  before_action :ensure_configured
  before_action :set_booking, only: [:show, :update, :success, :cancel]

  def update
    command = command_klass(:update).new(params, @base_klass, current_user, options)
    @result = command.run

    respond_to do |format|
      format.html do
        if @result[:success]
          flash[:success] = @result[:message]
          redirect_to booking_path(@result[:booking_id])
        else
          flash[:alert] = @result[:message]
          redirect_to dashboard_path(current_user)
        end
      end
      format.json do
        if @result[:success]
          render json: { data: @result }, status: :ok
        else
          render json: { error: @result[:message] }, status: :unprocessable_entity
        end
      end
    end
  rescue BaseCommand::CommandError => e
    respond_to do |format|
      format.html do
        flash[:alert] = e.message
        redirect_to dashboard_path(current_user)
      end
      format.json do
        render json: { error: e.message }, status: e.status_code || :unprocessable_entity
      end
    end
  rescue => e
    respond_to do |format|
      format.html do
        flash[:alert] = "Internal server error"
        redirect_to dashboard_path(current_user)
      end
      format.json do
        render json: { error: "Internal server error" }, status: :internal_server_error
      end
    end
  end
  
  def show
    @payment = Payment.find(params[:id])
    @stripe_public_key = Rails.configuration.stripe[:publishable_key]
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

  def ensure_configured
    StripeConfig.ensure_configured!
  end
end 