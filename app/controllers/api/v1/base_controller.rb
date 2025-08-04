class Api::V1::BaseController < ApplicationController
  before_action :set_base_klass
  respond_to :json
  include JsonHandler
  include FieldsValidator

  def index
    command = command_klass(:index).new(params, @base_klass, current_user, options)
    result = command.run
    render_json(@base_klass, result, :ok)
  rescue BaseCommand::CommandError => e
    render_error(e.error_message, e.status_code)
  rescue => e
    Rails.logger.error("Error in index action: #{e.message}")
    render_error("Internal server error", :internal_server_error)
  end

  def show
    command = command_klass(:show).new(params, @base_klass, current_user, options)
    result = command.run

    render_json(@base_klass, result, :ok)
  rescue BaseCommand::CommandError => e
    render_error(e.error_message, e.status_code)
  rescue => e
    Rails.logger.error("Error in show action: #{e.message}")
    render_error("Internal server error", :internal_server_error)
  end

  def create
    command = command_klass(:create).new(params, @base_klass, current_user, options)
    result = command.run

    render_json(@base_klass, result, :created)
  rescue BaseCommand::CommandError => e
    render_error(e.error_message, e.status_code)
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.message, :unprocessable_entity)
  rescue => e
    Rails.logger.error("Error in create action: #{e.message}")
    # Rails.logger.error("Error in create action: #{e.backtrace.join("\n")}")
    render_error("Internal server error", :internal_server_error)
  end

  def update
    command = command_klass(:update).new(params, @base_klass, current_user, options)
    result = command.run

    render_json(@base_klass, result, :ok)
  rescue BaseCommand::CommandError => e
    render_error(e.error_message, e.status_code)
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.message, :unprocessable_entity)
  rescue => e
    Rails.logger.error("Error in update action: #{e.message}")
    render_error("Internal server error", :internal_server_error)
  end

  def destroy
    command = command_klass(:destroy).new(params, @base_klass, current_user, options)
    result = command.run

    render_json(result[:data], :ok, result[:meta_data])
  end

  private
  def set_base_klass
    klass_name = params[:controller].split('/').last
    @base_klass = klass_name.singularize.classify.constantize
    raise "Klass not found" unless @base_klass.present?
  end

  def options
    # add options according to action_name in contorller so that we can override options in contorller
    # handled options so far:
    # For index: filters, search_by, sort_by, sort_order
    @options ||= {}
  end

  def command_klass action_name
    "#{@base_klass.name}::#{action_name.capitalize}".constantize
  end
end