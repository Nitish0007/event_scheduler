class Api::V1::Organizers::RegistrationsController < Api::V1::Users::RegistrationsController

  # action for registering organizer
  def create
    error_msg = nil
    organizer = nil
    ActiveRecord::Base.transaction do
      begin
        # save user using devise registration
        super

        if resource.save
          organizer = Organizer.new(organizer_create_params)
          organizer.user_id = resource.id
          unless organizer.save
            error_msg = organizer.errors.full_messages
            Rails.logger.error ">>>>>>>>>>>> Organizer not saved: #{error_msg}"
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
      Rails.logger.error ">>>>>>>>>>>> Error registering Organizer: #{e.message}"
      raise ActiveRecord::Rollback
    end

    if error_msg.blank? && organizer.present? && organizer.persisted?
      render json: {
        message: "Organizer signed up successfully!!",
        organizer: organizer.as_json.merge({email: resource.email})
      }, status: :created
    else
      render json: {  errors: error_msg}, status: :unprocessable_entity
    end
  end

  private
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation).merge(role: :organizer)
  end

  def organizer_create_params
    params.require(:user).permit(:first_name, :last_name, :phone)
  end

end