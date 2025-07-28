class BaseController < ApplicationController
  before_action :set_base_klass

  def index
    command = command_klass(:index).new(params, @base_klass, current_user, options)
    @result = command.run
    instance_variable_set("@#{@base_klass.name.pluralize.underscore}", @result[:data])
    respond_to do |format|
      format.html { render :index }
    end
  end

  def show
    @base_resource = @base_klass.find(params[:id])
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

end