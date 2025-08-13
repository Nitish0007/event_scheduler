Rails.application.config.after_initialize do
  # Stripe.api_key = Rails.application.credentials.stripe[:secret_key]
  Stripe.api_key = ENV['STRIPE_SECRET_KEY']
  # Set the API version to ensure compatibility
  Stripe.api_version = '2023-10-16'
  
  # Configure webhook endpoint
  # if Rails.env.production?
  #   Stripe.webhook_endpoint = Rails.application.credentials.stripe[:webhook_secret]
  # else
  #   Stripe.webhook_endpoint = ENV['STRIPE_WEBHOOK_SECRET']
  # end
end 