class EventsController < BaseController
  before_action :allow_organizer_only, only: [:new, :create]
  # before_action :allow_customer_only, only: [:select_tickets]

  def new
    super
  end

  def create
    super
  end

  # not created command for this action because this is a view only action
  # def select_tickets
  #   show_event_path = "/users/#{current_user.id}/events/#{@event.id}"
  #   if @event.tickets.count == 0 || @event.tickets.sum(&:available_count) == 0
  #     flash[:alert] = "No ticket available for this event"
  #     redirect_to show_event_path
  #     return
  #   end
  #   render :select_tickets, locals: { event: @event, show_event_path: show_event_path }
  # end

  private

  def set_event
    @event = Event.find(params[:id])
  end
end