class Api::V1::CustomersController < ApplicationController

  def index
    customers = User.where(role: :customer)
    render json: { data: customers }, status: :ok
  end

end