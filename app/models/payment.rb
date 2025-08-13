class Payment < ApplicationRecord
  belongs_to :booking
  belongs_to :user
  
  enum status: { pending: 0, processing: 1, completed: 2, failed: 3, refunded: 4, cancelled: 5 }
  enum payment_method: { stripe: 0, paypal: 1, bank_transfer: 2 }
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :stripe_payment_intent_id, uniqueness: true, allow_nil: true
  
  before_create :generate_reference_number
  
  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: :completed) }

  def self.payment_methods
    {
      'stripe' => 'Card',
      'upi' => 'UPI'
    }
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
      self.reference_number = "PAY-#{SecureRandom.alphanumeric(8).upcase}"
      break unless Payment.exists?(reference_number: reference_number)
    end
  end
end 