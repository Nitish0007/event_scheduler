class Api::V1::BookingsController < ApplicationController
  before_action :allow_customer_only, only: [:create, :destroy]

  def index
    # returns the bookings of current customer
    customer_id = current_user.customer.id
    bookings = Booking.where(customer_id: customer_id)
    if params[:event_id].present?
      bookings = bookings.where(event_id: params[:event_id])
    end

    render json: { data: bookings }, status: :ok
  end

  def create
    booking = Booking.new(booking_params)
    if booking.save
      render json: { data: booking }, status: :created
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
    params.require(:booking).permit(:customer_id, :ticket_id, :quantity)
  end
end