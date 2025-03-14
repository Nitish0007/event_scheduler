class Api::V1::Users::SessionsController < Devise::SessionsController
  skip_forgery_protection #if: -> { request.format.json? }
  
  # Created this controller because
  # if just in case in future some additional functionality needs to be added while login/logout for both users(customers/organizer) that is different from the implementation of devise registration
end