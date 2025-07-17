class Api::V1::EventsController < ApplicationController
  before_action :allow_organizer_only, only: [:create, :update]

  def index
    events = Event.all.includes(:tickets)
    if params[:organizer_id]
      events = events.where(userr_id: params[:organizer_id])
    end

    render json: {data: events.map{ |e| e.as_json(include: [:tickets])}}, status: :ok
  end

  def show
    event = Event.find_by_id(params[:id])
    if event.present?
      render json: {data: event.as_json(include: [:tickets])}, status: :ok
    else
      render json: {errors: ["event not found"]}, status: :not_found
    end
  end

  def create
    event = Event.new(event_params)
    if event.save
      # Reload the event to get updated values after after_commit callbacks
      event.reload
      render json: {data: event}, status: :created
    else
      render json: {errors: event.errors}, status: :unprocessable_entity
    end
  end

  def update
    event = Event.find_by_id(params[:id])
    if event.present?
      if event.update(event_params)
        # Reload the event to get updated values after after_commit callbacks
        event.reload
        render json: {data: event.as_json(include: [:tickets])}, status: :ok
      else
        render json: {errors: event.errors}, status: :unprocessable_entity
      end
    else
      render json: {errors: ["event not found"]}, status: :not_found
    end
  end

  def destroy
    event = Event.find_by_id(params[:id])
    if event.present?
     if event.destroy
      render json: {message: "Event deleted successfully"}, status: :ok
     else
      render json: {errors: event.errors}, status: :unprocessable_entity
     end
    else
      render json: {errors: ["event not found"]}, status: :unprocessable_entity
    end
  end

  private
  def event_params
    params.require(:event).permit(:event_title, :event_date, :event_venue, :user_id, tickets_attributes: [:id, :ticket_type, :price_per_ticket, :tickets_count, :booked_ticket_count, :_destroy])
  end
end