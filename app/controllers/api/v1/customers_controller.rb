class Api::V1::CustomersController < ApplicationController

  def index
    customers = Customer.all.includes(:user)
    customers = customers.map do |c|
      c.as_json.merge(email: c.user.email)
    end
    render json: { data: customers }, status: :ok
  end

end