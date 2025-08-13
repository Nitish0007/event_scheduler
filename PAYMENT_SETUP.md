# Payment Integration Setup Guide

This guide will help you set up the payment system for your Event Scheduler application using Stripe.

## Prerequisites

- Ruby on Rails 7.1+
- PostgreSQL database
- Stripe account (https://stripe.com)

## Installation Steps

### 1. Install Dependencies

```bash
bundle install
```

### 2. Set up Stripe Credentials

Add your Stripe credentials to `config/credentials.yml.enc`:

```bash
rails credentials:edit
```

Add the following content:

```yaml
stripe:
  public_key: pk_test_your_public_key_here
  secret_key: sk_test_your_secret_key_here
  webhook_secret: whsec_your_webhook_secret_here
```

### 3. Run Database Migrations

```bash
rails db:migrate
```

### 4. Set up Stripe Webhook

1. Go to your Stripe Dashboard
2. Navigate to Developers > Webhooks
3. Add endpoint: `https://yourdomain.com/webhooks/stripe`
4. Select events:
   - `payment_intent.succeeded`
   - `payment_intent.payment_failed`
   - `payment_intent.canceled`
5. Copy the webhook signing secret and add it to your credentials

### 5. Environment Variables

Add to your `.env` file:

```bash
STRIPE_PUBLIC_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

## Features

### Payment Flow

1. **User creates a booking** - Booking status: `pending`
2. **User proceeds to payment** - Booking status: `payment_pending`
3. **Payment processing** - Payment status: `processing`
4. **Payment successful** - Payment status: `completed`, Booking status: `confirmed`
5. **Payment failed** - Payment status: `failed`, Booking status: `payment_failed`

### Payment Methods

- Credit/Debit Cards (via Stripe)
- Secure payment processing
- Real-time payment status updates
- Webhook handling for payment confirmations

### Security Features

- CSRF protection
- Stripe signature verification
- Secure payment intent creation
- PCI compliance through Stripe

## API Endpoints

### Payments

- `POST /users/:user_id/bookings/:booking_id/payments` - Create payment
- `GET /users/:user_id/bookings/:booking_id/payments/new` - Payment form
- `GET /users/:user_id/bookings/:booking_id/payments/:id` - Payment details
- `GET /users/:user_id/bookings/:booking_id/payments/success` - Payment success
- `GET /users/:user_id/bookings/:booking_id/payments/cancel` - Cancel payment

### Webhooks

- `POST /webhooks/stripe` - Stripe webhook endpoint

## Testing

### Test Cards

Use these test card numbers for testing:

- **Success**: 4242 4242 4242 4242
- **Decline**: 4000 0000 0000 0002
- **Requires Authentication**: 4000 0025 0000 3155

### Test Mode

The application automatically uses test mode when using test keys. All transactions will be test transactions.

## Production Deployment

### 1. Update Credentials

Replace test keys with production keys in credentials:

```bash
rails credentials:edit
```

### 2. Update Webhook URL

Update your Stripe webhook endpoint to your production domain.

### 3. SSL Certificate

Ensure your production environment has a valid SSL certificate for secure payment processing.

### 4. Environment Variables

Set production environment variables on your hosting platform.

## Monitoring

### Stripe Dashboard

Monitor payments, refunds, and disputes through your Stripe Dashboard.

### Application Logs

Check application logs for payment processing errors and webhook events.

### Webhook Events

Monitor webhook delivery and retry attempts in your Stripe Dashboard.

## Troubleshooting

### Common Issues

1. **Payment Intent Creation Fails**
   - Check Stripe API key configuration
   - Verify amount format (cents vs dollars)
   - Check Stripe account status

2. **Webhook Not Receiving Events**
   - Verify webhook endpoint URL
   - Check webhook secret configuration
   - Ensure endpoint is accessible from Stripe

3. **Payment Not Confirming**
   - Check webhook event handling
   - Verify payment intent status
   - Check database transaction logs

### Support

- Stripe Support: https://support.stripe.com
- Application Logs: Check `log/` directory
- Database: Check payment and booking records

## Security Considerations

- Never log sensitive payment information
- Use HTTPS in production
- Regularly rotate API keys
- Monitor for suspicious activity
- Implement rate limiting for payment endpoints
- Validate all webhook signatures

## Performance Optimization

- Use background jobs for email notifications
- Implement caching for payment status
- Monitor database query performance
- Use database indexes for payment lookups 