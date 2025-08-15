class PaymentSyncService < BaseApiService
  # NOTE: this is incomplete
  # This was planned to be used to sync payments from stripe to our database manually without webhooks
  # This is not used in the app currently
  def initialize(api_key, payload={})
    super(api_key, payload)
  end

  def base_url
    'https://api.stripe.com/v1'
  end

  
end