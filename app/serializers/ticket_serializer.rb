class TicketSerializer < ApplicationSerializer
  attributes :ticket_type, :price_per_ticket, :tickets_count, :booked_ticket_count, :event_id
  
  # Include associations
  # belongs_to :event
  
  # Custom methods
  def available_tickets
    object.tickets_count - object.booked_ticket_count
  end
  
  def price_per_ticket
    object.price_per_ticket.to_f
  end
end 