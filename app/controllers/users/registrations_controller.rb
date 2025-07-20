class Users::RegistrationsController < Devise::RegistrationsController

  layout 'auth'
  
  before_action :set_devise_mapping
  
  # GET /resource/sign_up
  def new
    super
  end
  
  # POST /resource
  def create
    build_resource(sign_up_params)
    
    if resource.save
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
  
  # GET /resource/edit
  def edit
    super
  end
  
  # PUT /resource
  def update
    super
  end
  
  # DELETE /resource
  def destroy
    super
  end
  
  private
  
  def set_devise_mapping
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation).merge(role: :organizer)
  end
  
  # Override the resource class to use User model
  def resource_class
    User
  end

  # Override devise mapping to use the user mapping
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  # Override resource name to use :user
  def resource_name
    :user
  end

  # Redirect after successful sign up
  def after_sign_up_path_for(resource)
    # Redirect to a welcome page or dashboard
    new_organizer_sign_in_path
  end
end