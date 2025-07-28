class BookingSerializer < ApplicationSerializer
  attributes :quantity, :user_id, :ticket_id, # :total_amount
  
  # Include associations
  # belongs_to :user
  belongs_to :ticket
  
  # Custom methods
  # def total_amount
  #   object.quantity * object.ticket.price_per_ticket
  # end
end 