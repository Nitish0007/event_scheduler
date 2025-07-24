class Users::SessionsController < Devise::SessionsController
  layout 'auth'

  before_action :set_devise_mapping
  skip_before_action :authenticate_user!, only: [:new, :create]

  def new
    super
  end

  def create
    begin
      ################################### DON NOT REMOVE THIS COMMENT ####################################
      #                                                                                                  #
      #  NOTE: This flow is kept for reference of internal devise methods for future projects            #
      #                                                                                                  #
      #  self.resource = warden.authenticate!(auth_options) # validate the user credentials              #
      #  sign_in(resource_name, resource) # sign in the user -> store the user id in the session cookie  #
      #  redirect_to after_sign_in_path_for(resource)                                                    #
      #                                                                                                  #          
      ################################### DON NOT REMOVE THIS COMMENT ####################################

      super
      Rails.logger.info "====================== #{user_signed_in?}"
    rescue => e
      Rails.logger.error "----------------- Error: #{e.inspect}"
      redirect_to new_user_sign_in_path, alert: "Invalid email or password"
    end
  end
  

  def destroy
    # Sign out the user manually
    sign_out(:user) if current_user
    
    # Redirect to the after sign out path
    return redirect_to after_sign_out_path_for(nil), status: :see_other
  end

  private
  
  def sign_in_params
    params.require(:user).permit(:email, :password) if params[:user].present?
  end
  
  def set_devise_mapping
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # Override devise mapping to use the user mapping
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # Override the resource class to use User model
  def resource_class
    User
  end

  # Override resource name to use :user
  def resource_name
    :user
  end

  def after_sign_in_path_for(resource)
    dashboard_path(resource)
  end

  def after_sign_out_path_for(resource_or_scope)
    welcome_path # redirect to welcome page
  end

  def new_user_sign_in_path
    params[:controller] == "organizers/sessions" ? new_organizer_sign_in_path : new_customer_sign_in_path
  end
end