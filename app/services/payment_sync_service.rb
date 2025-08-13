class PaymentSyncService < BaseApiService
  def initialize(api_key, payload={})
    super(api_key, payload)
  end

  def base_url
    'https://api.stripe.com/v1'
  end

  
end