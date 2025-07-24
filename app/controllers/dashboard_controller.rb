class DashboardController < ApplicationController
  
  def welcome
    render :welcome, layout: 'welcome'
  end

  def dashboard
    if user_signed_in?
      @user = current_user
      render :dashboard
    else
      redirect_to welcome_path
    end
  end
end