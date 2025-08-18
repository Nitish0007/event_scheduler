class Booking::Create < CreateCommand

  def run
    begin
      ActiveRecord::Base.transaction do
        # find ticket of given ticket_type for given event_id
        tickets = Ticket.find_by(ticket_type: @params[:booking][:ticket_type], event_id: @params[:booking][:event_id])
        if tickets.blank? || tickets.available_count < resource_params[:quantity].to_i
          raise_bad_request_error("'#{@params[:booking][:ticket_type]}' tickets not available for this event, try with less quantity or different ticket type", :unprocessable_entity)
        end
        resource_params.merge!(ticket_id: tickets&.id, total_amount: tickets&.price_per_ticket * resource_params[:quantity].to_i, status: :payment_pending, currency: 'inr')

        # find booking for given user_id and ticket_id and same quantity with status payment_pending
        message = nil
        booking = Booking.find_by(user_id: @user.id, ticket_id: tickets&.id, quantity: resource_params[:quantity], status: :payment_pending)
        if booking.present? && booking.presisted? 
          resource = booking
          if booking.payments.where(status: [:completed]).any?
            raise_bad_request_error("You have already completed the payment for this booking", :unprocessable_entity)
          end
          message = "Complete the payment to confirm your booking"
        else
          resource = Booking.new(resource_params) # create booking with pending status
          message = "Your booking request is created, please proceed to payment and complete the process"
        end
        payment = resource.payments.where(status: :pending).first_or_initialize

        payment.update!(
          user_id: @user.id,
          booking_id: resource.id,
          amount: tickets&.price_per_ticket * resource_params[:quantity].to_i,
          currency: resource_params[:currency],
        )

        if resource.save
          resource.reload
          return {
            message: message,
            data: resource,
            payment_id: payment.id
          }
        end
      end
    rescue BaseCommand::CommandError => e
      raise e
    rescue => e
      raise e
    end
  end

  # private
  # def permitted_attributes klass=@klass
  #   [:user_id, :ticket_id, :quantity, :event_id, :ticket_type]
  # end
end