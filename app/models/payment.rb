class Payment < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  
  enum status: { pending: 0, processing: 1, completed: 2, failed: 3, refunded: 4, cancelled: 5 }
  enum payment_method: { card: 0, upi: 1, bank_transfer: 2 }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :stripe_payment_intent_id, uniqueness: true, allow_nil: true
  
  before_create :generate_reference_number
  
  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: :completed) }

  def self.payment_methods
    {
      'card' => 'Card',
      'upi' => 'UPI'
    }
  end

  def self.create_stripe_payment_intent(payment)
    payment_intent = Stripe::PaymentIntent.create(
      amount: (payment.amount * 100).to_i,
      currency: payment.currency,
      payment_method_types: [payment.payment_method],
      metadata: {
        booking_id: payment.booking_id,
        user_id: payment.user_id
      },
      description: "Payment for event #{payment.booking.event_title}: #{payment.booking.quantity} #{payment.booking.ticket_type} ticket(s)"
    )
    return payment_intent
  end

  def self.process_payment(payment_id)
    ActiveRecord::Base.transaction do
      StripeConfig.ensure_configured!
      payment = Payment.find(payment_id)

      # check available tickets to avoid overbooking
      available_tickets_key = "available_tickets_#{payment.booking.ticket.event_id}_#{payment.booking.ticket_type}"
      quantity = payment.booking.quantity

      unless RedisStore.exists?(available_tickets_key)
        available_tickets_count = payment.booking.ticket.available_count
        RedisStore.set(available_tickets_key, available_tickets_count)
      end

      if RedisStore.get(available_tickets_key).to_i < quantity
        payment.update!(status: :failed)
        RedisStore.delete("payment_ref_#{payment.reference_number}")
        return
      end

      # create stripe payment intent
      payment_intent = Payment.create_stripe_payment_intent(payment)
      payment.update!(stripe_payment_intent_id: payment_intent.id)

      # update booking status to payment_processing
      payment.booking.update!(status: :payment_processing)

      # update available tickets count in redis store
      new_available_count = RedisStore.decrby(available_tickets_key, payment.booking.quantity)
      if new_available_count < 0
        payment.update!(status: :failed)
        RedisStore.incrby(available_tickets_key, payment.booking.quantity)
        RedisStore.delete("payment_ref_#{payment.reference_number}")
        Rails.logger.error ">>>>>>>> Available tickets count is less than quantity for payment: #{payment.id}"
        raise ActiveRecord::Rollback
      end
      RedisStore.delete("payment_ref_#{payment.reference_number}")
    end
  rescue StandardError => e
    Rails.logger.error ">>>>>>> Error in process payment job: #{e.message}"
    raise e
  end

  def sync_with_stripe
    if stripe_payment_intent_id.present?
      payment_intent = Stripe::PaymentIntent.retrieve(stripe_payment_intent_id)
      if payment_intent.status == "succeeded"
        self.update!(status: :completed)
        self.booking.update!(status: :confirmed)
      elsif payment_intent.status == "failed"
        self.update!(status: :failed)
        self.booking.update!(status: :payment_failed)
      elsif payment_intent.status == "canceled"
        self.update!(status: :cancelled)
        self.booking.update!(status: :payment_failed)
      elsif payment_intent.status == "processing"
        self.update!(status: :processing)
        self.booking.update!(status: :payment_processing)
      end
    else
      self.update!(status: :failed)
      self.booking.update!(status: :payment_failed)
    end
  end

  def total_amount
    amount + (fee || 0)
  end
  
  def formatted_amount
    "#{currency.upcase} #{'%.2f' % total_amount}"
  end
  
  def stripe_payment_url
    return nil unless stripe_payment_intent_id.present?
    "https://dashboard.stripe.com/payments/#{stripe_payment_intent_id}"
  end
  
  private
  
  def generate_reference_number
    loop do
      self.reference_number = "esPAY-#{SecureRandom.alphanumeric(8).upcase}-#{Time.now.strftime('%Y%m%d%H%M%S%L%N')}"
      break unless Payment.exists?(reference_number: reference_number)
    end
  end
end 