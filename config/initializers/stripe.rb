Rails.configuration.stripe = {
  publishable_key: ENV.fetch('STRIPE_PUBLIC_KEY'), # this is used in the frontend to initialize stripe
  secret_key: ENV.fetch('STRIPE_SECRET_KEY'), # this is used to create the payment intent in backend
  webhook_secret: ENV.fetch('STRIPE_WEBHOOK_SECRET') # this is used in the stripe controller to verify the signature of the webhook
}

module StripeConfig
  def self.ensure_configured!
    unless Stripe.api_key.present?
      Stripe.api_key = Rails.configuration.stripe[:secret_key]
      Stripe.api_version = '2023-10-16' # Set the API version to ensure compatibility
    end
  end
end

StripeConfig.ensure_configured!

Rails.application.config.after_initialize do
  StripeConfig.ensure_configured!
end
