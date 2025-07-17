class Api::V1::Customers::RegistrationsController < Api::V1::Users::RegistrationsController
  
  # action for registering customer
  def create
    error_msg = nil
    
    begin
      super # initialize user using devise's build_resource method

      unless resource.save
        error_msg = resource.errors.full_messages
        Rails.logger.error ">>>>>>>>>>>> User not created: #{error_msg}"
      end
    rescue => e
      error_msg ||= [e.message]
      Rails.logger.error ">>>>>>>>>>>> Error registering Customer: #{e.message}"
    end

    if error_msg.blank?
      render json: {
        message: "Customer signed up successfully!!",
        customer: resource.as_json
      }, status: :created
    else
      render json: {  errors: error_msg}, status: :unprocessable_entity
    end
  end

  private
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :phone, :email, :password, :password_confirmation).merge(role: :customer)
  end
end