class TicketSerializer < ApplicationSerializer
  attributes :event_id, :ticket_type, :price_per_ticket, :tickets_count, :booked_ticket_count, :available_count
end 