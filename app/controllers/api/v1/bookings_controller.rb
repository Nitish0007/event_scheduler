class Api::V1::BookingsController < ApplicationController
  before_action :allow_customer_only, only: [:create, :destroy]

  def index
    bookings = Booking.where(user_id: current_user.id)
    if params[:event_id].present?
      bookings = bookings.where(event_id: params[:event_id])
    end

    render json: { data: bookings }, status: :ok
  end

  def create
    event = Event.find_by_id(params[:booking][:event_id])
    if event.present?
      ticket_id = event.tickets.where(ticket_type: params[:booking][:ticket_type]).first&.id
      unless ticket_id.present?
        render json: { errors: ["No '#{params[:booking][:ticket_type]}' tickets available for this event"] }, status: :unprocessable_entity
      end
      params[:booking][:ticket_id] = ticket_id
    end
    booking = Booking.new(booking_params)

    if booking.save
      render json: { data: "Your Request is being processed you will get email on booking status" }, status: :created
    else
      render json: { errors: booking.errors }, status: :unprocessable_entity
    end
  end

  def update
    # no plan to update bookings for now
  end

  def destroy
    # trigger destroy on cancel bookings
    booking = Booking.find_by_id(params[:id])
    if booking.present?
      if booking.destroy
        render json: { message: 'Booking cancelled' }, status: :ok
      else
        render json: { errors: booking.errors }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Not found"] }, status: :not_found
    end
  end

  private
  def booking_params
    params.require(:booking).permit(:user_id, :quantity, :ticket_id)
  end
end