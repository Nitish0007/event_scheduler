class Payment::Update < UpdateCommand
  def run
    begin
      ActiveRecord::Base.transaction do
        payment = Payment.find_by(id: @params[:id], user_id: @user.id)
        payment_params.merge!(payment_method: payment_params[:payment_method].to_sym)
        if payment.nil?
          return {
            success: false,
            message: "Payment not found",
            status_code: :not_found
          }
        end
        # use payment reference number to avoid duplicate payments of processing same payment multiple times
        if RedisStore.exists?("payment_ref_#{payment.reference_number}")
          return {
            success: true,
            payment_id: payment.id,
            booking_id: payment.booking_id,
            message: "Payment is already being processed"
          }
        end
        RedisStore.set("payment_ref_#{payment.reference_number}", true)
        payment.update!(status: :processing, payment_method: payment_params[:payment_method].to_sym)
        
        # Create Stripe PaymentIntent if it's a Stripe payment
        if payment_params[:payment_method] == :card || payment_params[:payment_method] == 'card'
          payment_intent = Payment.create_stripe_payment_intent(payment)
          payment.update!(stripe_payment_intent_id: payment_intent.id)
          Rails.logger.info ">>>>>>>>>>>>> Payment intent: #{payment_intent.inspect}"
          
          result = {
            success: true,
            client_secret: payment_intent.client_secret,
            payment_id: payment.id,
            booking_id: payment.booking_id
          }
        else
          result = {
            success: true,
            payment_id: payment.id,
            booking_id: payment.booking_id
          }
        end
        message = "Payment is being processed"

        if queue_overloaded?
          message = "Payment is being processed, it may take a little longer due to heavy traffic"
          # this will be handled by cron job running every 2 minutes for bulk payment processing
        else
          # can be processed immediately
          ProcessPaymentJob.perform_async(payment.id)
        end

        return result.merge(message: message)
      rescue StandardError => e
        RedisStore.delete("payment_ref_#{payment.reference_number}")
        Rails.logger.error "Payment update error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        raise BaseCommand::CommandError.new({message: "Failed to update payment", status_code: :internal_server_error})
      end
    rescue BaseCommand::CommandError => e
      raise e
    rescue => e
      raise e
    end
  end

  private
  def payment_params
    @params.require(:payment).permit(:payment_method)
  end

  def queue_overloaded?
    Sidekiq::Queue.new('payment_processor').size > 500
  end
end