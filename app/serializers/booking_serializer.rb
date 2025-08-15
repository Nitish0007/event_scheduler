class BookingSerializer < ApplicationSerializer
  attributes :id, :quantity, :user_id, :ticket_id, :total_amount, :status, 
             :created_at, :updated_at
  
  belongs_to :ticket
  has_many :payments
  
  # def payment_status 
  #   object.payments.last.status
  # end
  
  # def can_cancel
  #   object.can_cancel?
  # end
end 