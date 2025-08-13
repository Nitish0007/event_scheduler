class Payment::Create < CreateCommand

  def run
    begin
      ActiveRecord::Base.transaction do
        @booking = Booking.find_by(id: @params[:booking_id], user_id: @user.id)
        @booking.update!(status: :payment_pending)
        Rails.logger.info "Payment params: #{payment_params.inspect}"
        @payment = Payment.new(
          payment_params.merge(user_id: @user.id, booking_id: @booking.id, amount: @booking.total_amount, currency: 'inr')
        )
      
        if @payment.save
          begin
            # Create Stripe Payment Intent
            payment_intent = Stripe::PaymentIntent.create(
              amount: (@payment.amount * 100).to_i, # Stripe expects amount in cents
              currency: @payment.currency,
              metadata: {
                booking_id: @booking.id,
                payment_id: @payment.id,
                user_id: @user.id
              },
              description: "Payment for event #{@booking.event_title}: #{@booking.quantity} #{@booking.ticket_type} ticket(s)"
            )
            
            @payment.update!(
              stripe_payment_intent_id: payment_intent.id,
              status: :processing
            )
            
            @booking.update!(status: :payment_pending)
            
            # Return success data
            return {
              success: true,
              client_secret: payment_intent.client_secret,
              payment_id: @payment.id
            }
          rescue Stripe::StripeError => e
            @payment.update!(status: :failed)
            @booking.update!(status: :payment_failed)
            
            return {
              success: false,
              error: e.message
            }
          end
        else
          return {
            success: false,
            errors: @payment.errors.full_messages
          }
        end
      end
    rescue BaseCommand::CommandError => e
      raise e
    rescue => e
      raise e
    end
  end

  private
  
  def payment_params
    @params.require(:payment).permit!
  end

end