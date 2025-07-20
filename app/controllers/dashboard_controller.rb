class DashboardController < ApplicationController
  include Devise::Controllers::Helpers

  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:welcome]
  
  def welcome
    render :welcome, layout: 'welcome'
  end

  def dashboard
    if user_signed_in?
      @user = current_user
      render :dashboard
    else
      redirect_to welcome_path && return
    end
  end
end 