Rails.application.routes.draw do
  # devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # devise_for :organizers, controllers: {
  #   registrations: 'organizers/registrations',
  #   sessions: 'organizers/sessions'
  # }, skip: [:passwords]

  # devise_for :customers, controllers: {
  #   registrations: 'customers/registrations',
  #   sessions: 'customers/sessions'
  # }, skip: [:passwords]

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: { registrations: 'api/v1/users/registrations' }, skip: [:sessions, :passwords]

      devise_scope :api_v1_user do
        # sign_up routes
        post 'organizers/sign_up', to: 'organizers/registrations#create'
        post 'customers/sign_up', to: 'customers/registrations#create'

        # sign_in routes
        post 'organizers/sign_in', to: 'organizers/sessions#create'
        post 'customers/sign_in', to: 'customers/sessions#create'
      end

    end
  end
end
