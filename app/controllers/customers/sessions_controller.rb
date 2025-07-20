class Customers::SessionsController < Users::SessionsController
  # using users/sessions_controller to avoid code duplication
  # and to use the same layout for both organizers and customers
  # this file was created to keep routing simple for customers 
end