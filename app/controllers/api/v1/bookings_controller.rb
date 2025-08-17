class Api::V1::BookingsController < Api::V1::BaseController
  before_action :allow_customer_only, only: [:create, :destroy]
  before_action :set_ticket, only: [:create]

  def create
    command = command_klass(:create).new(params, @base_klass, current_user, options)
    @result = command.run
    render_json(@base_klass, @result, :created)
  rescue BaseCommand::CommandError => e
    render_error(e.error_message, e.status_code)
  rescue => e
    render_error("Internal server error", :internal_server_error)
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
  def create_params
    params.require(:booking).permit(:user_id, :quantity, :ticket_id)
  end

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
    @booking = Booking.new(ticket_id: @ticket.id)
  end

  def options
    @options ||= {}
    case action_name
    when "index"
      filters = { user_id: current_user.id }
      filters[:event_id] = params[:event_id] if params[:event_id].present?
      @options = @options.merge(filters: filters)
    end
    return @options
  end
end