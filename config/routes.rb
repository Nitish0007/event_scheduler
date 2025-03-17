Rails.application.routes.draw do
  require 'sidekiq/web'

  Rails.application.routes.draw do 
    mount Sidekiq::Web => '/sidekiq'
  end
  

  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do

      # --------------------   ROUTES FOR AUTHENTICATION   -------------------- #
      devise_for :users,
      controllers: {
        registrations: 'api/v1/users/registrations',
        sessions: 'api/v1/users/sessions'
      },
      skip: [:password],
      defaults: { format: :json }

      devise_scope :api_v1_user do
        # sign_up routes
        post 'organizers/sign_up', to: 'organizers/registrations#create'
        post 'customers/sign_up', to: 'customers/registrations#create'

        # sign_in routes
        post 'organizers/sign_in', to: 'organizers/sessions#create'
        post 'customers/sign_in', to: 'customers/sessions#create'
      end
      # ----------------------------------------------------------------------- #

      # routes will be accessible by user_id to authenticate on the roles basis
      scope path: "/:user_id" do
        resources :organizers
        resources :customers
        resources :events
        resources :tickets
        resources :bookings
      end
    end
  end

end
