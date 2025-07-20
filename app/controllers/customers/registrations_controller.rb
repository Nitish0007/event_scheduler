class Customers::RegistrationsController < Users::RegistrationsController
  # using users/registrations_controller to avoid code duplication
  # and to use the same layout for both organizers and customers
  # this file was created to keep routing simple for customers
end