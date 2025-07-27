class Api::V1::TicketsController < Api::V1::BaseController
  before_action :allow_organizer_only, only: [:create, :update, :destroy]

  def create
    ticket = Ticket.new(ticket_params)
    if ticket.save
      render json: { data: ticket }, status: :created
    else
      render json: { errors: ticket.errors }, status: :unprocessable_entity
    end
  end

  def update
    ticket = Ticket.find_by_id(params[:id])
    if ticket.present?
      if ticket.update(ticket_params)
        render json: { data: ticket }, status: :ok
      else
        render json: { errors: ticket.errors }, status: :unprocessable_entity
      end
    else
      render json: { errors: ["Not found"] }, status: :unprocessable_entity
    end
  end

  def destroy
    ticket = Ticket.find_by_id(params[:id])
    if ticket.nil?
      render json: { errors: "Ticket not found" }, status: :unprocessable_entity
    end
    if ticket.destroy
      render json: { messages: "Ticket destroyed", data: ticket }, status: :ok
    else
      render json: { errors: ticket.errors }, status: :unprocessable_entity
    end
  end

  private
  def ticket_params
    params.require(:ticket).permit(:ticket_type, :event_id, :price_per_ticket, :tickets_count, :booked_ticket_count)
  end

end