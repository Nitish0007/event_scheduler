# Event Scheduler

A comprehensive event management and ticketing system built with Ruby on Rails, featuring user authentication, event creation, ticket management, booking system, and integrated payment processing with Stripe.

## 🚀 Features

- **Multi-role User System**: Organizers and Customers with different permissions
- **Event Management**: Create, edit, and manage events with venue and date details
- **Ticket System**: Multiple ticket types with pricing and availability tracking
- **Booking Management**: Secure ticket booking with quantity and total amount calculation
- **Payment Integration**: Stripe payment processing with webhook support
- **Background Job Processing**: Sidekiq for asynchronous payment processing
- **RESTful API**: Versioned API endpoints for mobile and web applications
- **Modern UI**: Tailwind CSS for responsive and beautiful user interface
- **Real-time Updates**: Hotwire/Turbo for dynamic page updates

## 🏗️ Architecture

- **Backend**: Ruby on Rails 7.1.3
- **Database**: PostgreSQL
- **Authentication**: Devise with JWT tokens
- **Background Jobs**: Sidekiq with Redis
- **Payment Processing**: Stripe integration
- **Frontend**: Hotwire, Stimulus, Tailwind CSS
- **API**: RESTful API with JSON serialization

## 📋 Prerequisites

- Ruby 3.2.2
- Rails 7.1.3
- PostgreSQL 14+
- Redis 6+
- Node.js 16+

## ️ Installation

### 1. Clone the Repository
```bash
git clone https://github.com/Nitish0007/event_scheduler.git
cd event_scheduler
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Environment Setup
Create a `.env` file in the root directory:
```bash
# Authentication
DEVISE_JWT_SECRET_KEY=jwtqwertyuiop1234567890

# Database (if needed)
DATABASE_URL=postgresql://username:password@localhost/event_scheduler_development

# Stripe (for production)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

### 4. Database Setup
```bash
rails db:create
rails db:migrate
```

### 5. Start Services
```bash
# Terminal 1: Start Redis
redis-server

# Terminal 2: Start Sidekiq
bundle exec sidekiq

# Terminal 3: Start Rails Server
rails server
# or preferred to watch css changes as well
bin/dev
```

## 📋 Database Schema

### Core Models

- **Users**: Authentication and role management (organizer/customer)
- **Events**: Event details including title, venue, and date
- **Tickets**: Ticket types with pricing and availability
- **Bookings**: User ticket reservations with quantities
- **Payments**: Payment records with Stripe integration

### Key Relationships
- Users can create multiple events (organizers)
- Events have multiple tickets
- Users can book multiple tickets
- Bookings are linked to payments

##  API Endpoints

### Authentication
```
POST /api/v1/organizers/sign_up     # Organizer registration
POST /api/v1/customers/sign_up      # Customer registration
POST /api/v1/organizers/sign_in     # Organizer login
POST /api/v1/customers/sign_in      # Customer login
```

### Events
```
GET    /api/v1/:user_id/events      # List events
POST   /api/v1/:user_id/events      # Create event
GET    /api/v1/:user_id/events/:id  # Show event
PATCH  /api/v1/:user_id/events/:id  # Update event
DELETE /api/v1/:user_id/events/:id  # Delete event
```

### Tickets
```
GET    /api/v1/:user_id/tickets     # List tickets
POST   /api/v1/:user_id/tickets     # Create ticket
GET    /api/v1/:user_id/tickets/:id # Show ticket
PATCH  /api/v1/:user_id/tickets/:id # Update ticket
DELETE /api/v1/:user_id/tickets/:id # Delete ticket
```

### Bookings
```
GET    /api/v1/:user_id/bookings    # List bookings
POST   /api/v1/:user_id/bookings    # Create booking as well as payment associated with it
GET    /api/v1/:user_id/bookings/:id # Show booking
```

### Payments
```
GET    /api/v1/:user_id/bookings/:booking_id/payments/:id # Show payment
PATCH  /api/v1/:user_id/bookings/:booking_id/payments/:id # Update payment used for pay now
```

## 🔐 Authentication

The API uses JWT tokens for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

## 🎯 Payment Processing

### Stripe Integration
- Secure payment processing with Stripe
- Webhook support for payment status updates
- Background job processing for payment synchronization
- Support for multiple payment methods

### Payment Flow
1. User selects tickets and creates booking
2. Payment intent created with Stripe
3. User completes payment on Stripe
4. Webhook updates payment status
5. Background jobs sync payment data

## 🎯 Background Jobs

### Sidekiq Jobs
- **BulkPaymentProcessorJob**: Processes multiple payments in batches
- **SyncPaymentsJob**: Synchronizes payment data with Stripe which are not updated via webhooks
- **ProcessPaymentsInBatchJob**: Handles batch payment processing
<!-- - **BookingConfirmationJob**: Sends confirmation emails -->
- **EventUpdationJob**: Handles event updates

### Job Queues
- `default`: General background tasks
- `bulk_payment_processor`: Bulk Payment processing
- `payment_processor`: Payment processing
- `sync_payments`: syncing payments manually from stripe
<!-- - `mailers`: Email notifications -->

## 🎨 Frontend

### Technologies
- **Hotwire**: Real-time page updates
- **Stimulus**: JavaScript controllers
- **Tailwind CSS**: Utility-first CSS framework

### Key Components
- Responsive navigation and sidebar
- Modal dialogs for ticket selection
- Form components with validation
- Dashboard views for different user roles

## 🚀 Deployment

### Production Considerations
- Set proper environment variables
- Configure Stripe webhook endpoints
- Set up Redis for Sidekiq
- Configure PostgreSQL for production
- Set up SSL certificates

### Environment Variables
```bash
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key
DATABASE_URL=your_production_db_url
REDIS_URL=your_redis_url
STRIPE_PUBLIC_KEY=your_stripe_publishable_key # used for client side
STRIPE_SECRET_KEY=your_stripe_secret
STRIPE_WEBHOOK_SECRET=your_webhook_secret
```

## 📁 Project Structure

```
app/
├── commands/           # Command pattern implementations
├── controllers/        # API and web controllers
├── models/            # ActiveRecord models
├── services/          # Business logic services
├── jobs/              # Background job classes
├── mailers/           # Email templates and logic
├── serializers/       # JSON API serializers
└── views/             # ERB templates

config/
├── initializers/      # App configuration
├── routes.rb          # Route definitions
└── sidekiq.yml       # Sidekiq configuration

db/
├── migrate/           # Database migrations
└── schema.rb          # Current database schema
```

## 📝 Configuration

### Sidekiq
- Redis connection configuration
- Job queue management
- Cron job scheduling

### Stripe
- API key configuration
- Webhook endpoint setup
- Payment method configuration

### Devise
- JWT token configuration
- User authentication settings
- Role-based access control

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For questions, issues, or contributions, please contact:
- **Email**: 0007nitishsharma@gmail.com
- **GitHub Issues**: [Create an issue](https://github.com/Nitish0007/event_scheduler/issues)
---

**Happy Event Scheduling! 🎉**

This comprehensive README provides:

1. **Clear project overview** with features and architecture
2. **Detailed installation instructions** with all prerequisites
3. **API documentation** with all endpoints
4. **Database schema explanation** and relationships
5. **Authentication details** and JWT usage
6. **Payment processing flow** and Stripe integration
7. **Background job system** explanation
8. **Frontend technology stack** details
9. **Testing and deployment** instructions
10. **Project structure** overview
11. **Configuration details** for all major components
12. **Contributing guidelines** and support information


