class ApplicationSerializer < ActiveModel::Serializer
  # Base serializer that other serializers inherit from
  # Add common attributes or methods here
  
  # Example: Always include ID and timestamps
  attributes :id, :created_at, :updated_at
  
  # Example: Format timestamps consistently
  def created_at
    object.created_at&.iso8601
  end
  
  def updated_at
    object.updated_at&.iso8601
  end
end 