class Api::V1::Customers::RegistrationsController < Api::V1::Users::RegistrationsController
  
  # action for registering customer
  def create
    error_msg = nil
    customer = nil
    ActiveRecord::Base.transaction do
      begin
        # save user using devise registration
        super

        if resource.save
          customer = Customer.new(customer_create_params)
          customer.user_id = resource.id
          unless customer.save
            error_msg = customer.errors.full_messages
            Rails.logger.error ">>>>>>>>>>>> Customer not saved: #{error_msg}"
            raise ActiveRecord::Rollback
          end
        else
          error_msg = resource.errors.full_messages
          Rails.logger.error ">>>>>>>>>>>> User not created: #{error_msg}"
          raise ActiveRecord::Rollback
        end
      end
    rescue => e
      error_msg ||= [e.message]
      Rails.logger.error ">>>>>>>>>>>> Error registering Customer: #{e.message}"
      raise ActiveRecord::Rollback
    end

    if error_msg.blank? && customer.present? && customer.persisted?
      render json: {
        message: "Customer signed up successfully!!",
        organizer: customer.as_json.merge({email: resource.email})
      }, status: :created
    else
      render json: {  errors: error_msg}, status: :unprocessable_entity
    end
  end

  private
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation).merge(role: :customer)
  end

  def customer_create_params
    params.require(:user).permit(:first_name, :last_name, :phone, :company)
  end

end