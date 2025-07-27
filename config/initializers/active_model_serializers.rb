# Configure ActiveModelSerializers
ActiveModelSerializers.config.tap do |config|
  # Use JSON adapter (default)
  config.adapter = :json
  
  # Include root in JSON response (optional)
  # config.root = true
  
  # Set default serializer
  # config.default_serializer = ApplicationSerializer
  
  # Configure JSON key format (optional)
  # config.key_transform = :camel_lower
  
  # Configure JSON key format to snake_case
  # config.key_transform = :snake_case
  config.key_transform = nil
  
  # Disable root in JSON response
  config.root = false
end 