class Api::V1::EventsController < Api::V1::BaseController
  before_action :allow_organizer_only, only: [:create, :update]

  # def show
  #   event = Event.find_by_id(params[:id])
  #   if event.present?
  #     render json: {data: event.as_json(include: [:tickets])}, status: :ok
  #   else
  #     render json: {errors: ["event not found"]}, status: :not_found
  #   end
  # end

  # def create
  #   event = Event.new(create_params)
  #   if event.save
  #     # Reload the event to get updated values after after_commit callbacks
  #     event.reload
  #     render json: {data: event}, status: :created
  #   else
  #     render json: {errors: event.errors}, status: :unprocessable_entity
  #   end
  # end

  def update
    event = Event.find_by_id(params[:id])
    if event.present?
      if event.update(update_params)
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
  # def create_params
  #   params.require(:event).permit(:event_title, :event_date, :event_venue, :user_id, tickets_attributes: [:id, :ticket_type, :price_per_ticket, :tickets_count, :booked_ticket_count, :_destroy])
  # end

  def update_params
    params.require(:event).permit(:event_title, :event_date, :event_venue, :user_id, tickets_attributes: [:id, :ticket_type, :price_per_ticket, :tickets_count, :booked_ticket_count, :_destroy])
  end

  def options
    @options ||= {}
    case action_name
    when "index"
      filters = {}
      filters[:user_id] = params[:organizer_id] if params[:organizer_id].present?
      filters[:search_by] = params[:search_by] if params[:search_by].present?
      @options.merge!(filters: filters)
    when "show"
      @options ||= {}
    when "create"
      @options ||= {}
    end
    @options
  end
end