class EventSerializer < ApplicationSerializer
  attributes :id, :event_title, :event_venue, :event_date, :tickets_count, :user_id
  
  has_many :tickets
end 