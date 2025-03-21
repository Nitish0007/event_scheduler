# README

****------------ STEPS TO RUN ------------****

**Dependencies**

ruby version - 3.2.2

rails version - "rails", "~> 7.1.3", ">= 7.1.3.4"

postgresql(there is not strict version requirement, but try using 14, if other versions cause any issue)

redis installed

create .env file and add -> DEVISE_JWT_SECRET_KEY=jwtqwertyuiop1234567890


**Clone the repo and rub following commands in terminal** 

git clone https://github.com/Nitish0007/event_scheduler.git

cd event_scheduler


bundle install

rails db:create

rails db:migrate

**RUN REDIS locally using command**

redis-server

**RUN Sidekiq**

bundle exec sidekiq


**-------- ROUTES ---------**
- Authorization header needs to be passed as Bearer 'token', for accessing routes other than sign_in/sign_up

- For other routes token needs to be passed specific to user_id used in routes 

               api_v1_organizers_sign_up POST   /api/v1/organizers/sign_up(.:format)                                                              api/v1/organizers/registrations#create
                api_v1_customers_sign_up POST   /api/v1/customers/sign_up(.:format)                                                               api/v1/customers/registrations#create
               api_v1_organizers_sign_in POST   /api/v1/organizers/sign_in(.:format)                                                              api/v1/organizers/sessions#create
                api_v1_customers_sign_in POST   /api/v1/customers/sign_in(.:format)                                                               api/v1/customers/sessions#create


                       api_v1_organizers GET    /api/v1/:user_id/organizers(.:format)                                                             api/v1/organizers#index
                                         POST   /api/v1/:user_id/organizers(.:format)                                                             api/v1/organizers#create
                        api_v1_organizer GET    /api/v1/:user_id/organizers/:id(.:format)                                                         api/v1/organizers#show
                                         PATCH  /api/v1/:user_id/organizers/:id(.:format)                                                         api/v1/organizers#update
                                         PUT    /api/v1/:user_id/organizers/:id(.:format)                                                         api/v1/organizers#update
                                         DELETE /api/v1/:user_id/organizers/:id(.:format)                                                         api/v1/organizers#destroy
                        api_v1_customers GET    /api/v1/:user_id/customers(.:format)                                                              api/v1/customers#index
                                         POST   /api/v1/:user_id/customers(.:format)                                                              api/v1/customers#create
                         api_v1_customer GET    /api/v1/:user_id/customers/:id(.:format)                                                          api/v1/customers#show
                                         PATCH  /api/v1/:user_id/customers/:id(.:format)                                                          api/v1/customers#update
                                         PUT    /api/v1/:user_id/customers/:id(.:format)                                                          api/v1/customers#update
                                         DELETE /api/v1/:user_id/customers/:id(.:format)                                                          api/v1/customers#destroy
                           api_v1_events GET    /api/v1/:user_id/events(.:format)                                                                 api/v1/events#index
                                         POST   /api/v1/:user_id/events(.:format)                                                                 api/v1/events#create
                            api_v1_event GET    /api/v1/:user_id/events/:id(.:format)                                                             api/v1/events#show
                                         PATCH  /api/v1/:user_id/events/:id(.:format)                                                             api/v1/events#update
                                         PUT    /api/v1/:user_id/events/:id(.:format)                                                             api/v1/events#update
                                         DELETE /api/v1/:user_id/events/:id(.:format)                                                             api/v1/events#destroy
                          api_v1_tickets GET    /api/v1/:user_id/tickets(.:format)                                                                api/v1/tickets#index
                                         POST   /api/v1/:user_id/tickets(.:format)                                                                api/v1/tickets#create
                           api_v1_ticket GET    /api/v1/:user_id/tickets/:id(.:format)                                                            api/v1/tickets#show
                                         PATCH  /api/v1/:user_id/tickets/:id(.:format)                                                            api/v1/tickets#update
                                         PUT    /api/v1/:user_id/tickets/:id(.:format)                                                            api/v1/tickets#update
                                         DELETE /api/v1/:user_id/tickets/:id(.:format)                                                            api/v1/tickets#destroy
                         api_v1_bookings GET    /api/v1/:user_id/bookings(.:format)                                                               api/v1/bookings#index
                                         POST   /api/v1/:user_id/bookings(.:format)                                                               api/v1/bookings#create
                          api_v1_booking GET    /api/v1/:user_id/bookings/:id(.:format)                                                           api/v1/bookings#show
                                         PATCH  /api/v1/:user_id/bookings/:id(.:format)                                                           api/v1/bookings#update
                                         PUT    /api/v1/:user_id/bookings/:id(.:format)                                                           api/v1/bookings#update
                                         DELETE /api/v1/:user_id/bookings/:id(.:format)                                                           api/v1/bookings#destroy

for any quesry please reach out
Email: 0007nitishsharma@gmail.com
conact number: +91-9991529590



