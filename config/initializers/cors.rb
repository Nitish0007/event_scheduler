Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:80'

    resource '*',
              headers: :any,
              methods: [:get, :post, :update, :delete, :put, :patch, :head, :options], credentials: true
  end
end