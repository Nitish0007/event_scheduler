class Api::V1::OrganizersController < ApplicationController

  def index
    organizers = Organizer.all.includes(:user)
    organizers = organizers.map do |o|
      o.as_json.merge(email: o.user.email)
    end
    render json: {data: organizers }, status: :ok
  end

end