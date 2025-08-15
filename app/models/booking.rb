class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :ticket
  has_many :payments, dependent: :destroy
  
  enum status: { payment_pending: 0, confirmed: 1, cancelled: 2, failed: 3, payment_failed: 4, payment_completed: 5 }

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  
  def total_amount
    quantity * ticket.price_per_ticket
  end
  
  def payment_required?
    successful_payment.nil?
  end
  
  def can_cancel?
    %w[payment_pending payment_failed].include?(status)
  end
  
  def payment_status
    return 'unpaid' if payment.nil?
    payment.status
  end

  def successful_payment
    payments.find_by(status: :completed)
  end

  def payment
    successful_payment || payments.find_by(status: :pending)
  end

  def event_title
    ticket.event.event_title
  end

  def ticket_type
    ticket.ticket_type
  end

  def payable_payment
    if payment_required?
      payments.find_by(status: :pending)
    else
      payment
    end
  end

  def payment_id
    payable_payment&.id
  end

end