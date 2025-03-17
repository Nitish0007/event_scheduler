class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  skip_forgery_protection if: -> { request.format.json? } # to disable CSRF protection for API only requests
  skip_before_action :authenticate_request!, only: [:create]
  before_action :set_devise_mapping
  respond_to :json

  # Created this controller because
  # if just in case in future some common functionality needs to be added for creating (customers/organizer) that is different from the implementation of devise registration

  def create
    # save user manually just to avoid render or redirection of default create method of devise registration
    build_resource(sign_up_params)
  end

  private

  def set_devise_mapping
    request.env["devise.mapping"] = Devise.mappings[:user]
  end
end