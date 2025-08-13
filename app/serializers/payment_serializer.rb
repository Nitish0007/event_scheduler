class PaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :currency, :status, :payment_method, :reference_number, 
             :created_at, :updated_at, :total_amount, :formatted_amount
  
  belongs_to :booking
  belongs_to :user
  
  def total_amount
    object.total_amount
  end
  
  def formatted_amount
    object.formatted_amount
  end
end 