class Api::V1::OrganizersController < ApplicationController

  def index
    organizers = User.where(role: :organizer)
    render json: {data: organizers }, status: :ok
  end

end