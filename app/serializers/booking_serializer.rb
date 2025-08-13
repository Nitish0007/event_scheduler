class BookingSerializer < ApplicationSerializer
  attributes :id, :quantity, :user_id, :ticket_id, :total_amount, :status, 
             :created_at, :updated_at, :payment_status, :can_cancel
  
  belongs_to :ticket
  has_one :payment
  
  def payment_status
    object.payment_status
  end
  
  def can_cancel
    object.can_cancel?
  end
end 