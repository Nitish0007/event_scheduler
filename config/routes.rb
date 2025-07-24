Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  

  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  root "dashboard#welcome", as: :welcome

  # V1 API Routes
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

  # LEGACY ROUTES
  devise_for :users
  # --------------------   ROUTES FOR AUTHENTICATION   -------------------- #

  devise_scope :user do
    # sign_up routes
    get 'organizers/sign_up', to: 'organizers/registrations#new', as: :new_organizer_sign_up
    post 'organizers/sign_up', to: 'organizers/registrations#create', as: :organizer_sign_up
    get 'customers/sign_up', to: 'customers/registrations#new', as: :new_customer_sign_up
    post 'customers/sign_up', to: 'customers/registrations#create', as: :customer_sign_up
    
    # sign_in routes
    get 'organizers/sign_in', to: 'organizers/sessions#new', as: :new_organizer_sign_in
    post 'organizers/sign_in', to: 'organizers/sessions#create', as: :organizer_sign_in
    get 'customers/sign_in', to: 'customers/sessions#new', as: :new_customer_sign_in
    post 'customers/sign_in', to: 'customers/sessions#create', as: :customer_sign_in

    # sign_out routes
    delete 'organizers/sign_out', to: 'organizers/sessions#destroy', as: :organizer_sign_out
    delete 'customers/sign_out', to: 'customers/sessions#destroy', as: :customer_sign_out
  end
  # ----------------------------------------------------------------------- #

  scope :users do
    # routes will be accessible by user_id to authenticate on the roles basis
    scope path: "/:user_id" do
      get 'dashboard', to: 'dashboard#dashboard', as: :dashboard
      
      resources :organizers, only: [:index]
      resources :customers, only: [:index]
      resources :events
      resources :tickets
      resources :bookings
    end
  end

end
