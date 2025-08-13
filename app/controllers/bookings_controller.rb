class BookingsController < BaseController
  before_action :allow_customer_only, only: [:new, :create]
  before_action :set_ticket, only: [:new, :create]

  def new
    super
  end

  def show
    super
  end

  def create
    command = command_klass(:create).new(params, @base_klass, current_user, options)
    @result = command.run
    @booking = @result[:data]
    flash[:notice] = @result[:message]
    respond_to do |format|
      format.html { redirect_to "/users/#{current_user.id}/bookings/#{@booking.id}/payments/new" if @booking.payment_required? }
    end
  rescue BaseCommand::CommandError => e
    handle_error(e)
  rescue => e
    handle_error(e)
  end

  private
  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
    @booking = Booking.new(ticket_id: @ticket.id)
  end
end