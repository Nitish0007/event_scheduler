class BookingSerializer < ApplicationSerializer
  attributes :quantity, :user_id, :ticket_id, :total_amount, :status
  
  belongs_to :ticket
end 