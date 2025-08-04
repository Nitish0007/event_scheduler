class BaseController < ApplicationController
  before_action :set_base_klass

  def index
    command = command_klass(:index).new(params, @base_klass, current_user, options)
    @result = command.run
    instance_variable_set("@#{@base_klass.name.pluralize.underscore}", @result[:data])
    respond_to do |format|
      format.html { render :index }
    end
  rescue BaseCommand::CommandError => e
    handle_error(e)
  rescue => e
    handle_error(e)
  end

  def show
    command = command_klass(:show).new(params, @base_klass, current_user, options)
    result = command.run
    instance_variable_set("@#{@base_klass.name.singularize.underscore}", result[:data])
    
    respond_to do |format|
      format.html { render :show }
    end
  rescue BaseCommand::CommandError => e
    handle_error(e)
  rescue => e
    handle_error(e)
  end

  private
  def set_base_klass
    @base_klass = params[:controller].singularize.classify.constantize
    raise "Klass not found" unless @base_klass.present?
  end

  def command_klass action_name
    "#{@base_klass.name}::#{action_name.capitalize}".constantize
  end

  def options
    @options ||= {}
  end

  def back_url
    # customize this method to return different URLs based on context
    request.referer || root_path
  end

  def handle_error(error)
    # Log the full error for debugging
    Rails.logger.error "Error in #{controller_name}##{action_name}: #{error.message} \n"
    Rails.logger.error error.backtrace.join("\n") if Rails.env.development?
    
    # Use a safe, short flash message
    safe_message = if error.is_a?(BaseCommand::CommandError)
      error.message.truncate(50)
    else
      "An error occurred. Please try again."
    end
    
    flash[:alert] = safe_message
    
    # Use a safer redirect approach
    begin
      redirect_back(fallback_location: back_url, allow_other_host: false)
    rescue ActionController::RedirectBackError
      redirect_to back_url
    end
  end

end