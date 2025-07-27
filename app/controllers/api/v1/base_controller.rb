class Api::V1::BaseController < ApplicationController
  before_action :set_base_klass
  respond_to :json
  include JsonHandler

  def index
    command_class = "#{@base_klass.name}::Index".constantize
    command = command_class.new(params, @base_klass, current_user, options)
    result = command.run
    render_json(@base_klass, result, :ok)
  rescue BaseCommand::CommandError => e
    render_error(e.error_message, e.status_code)
  rescue => e
    Rails.logger.error("Error in index action: #{e.message}")
    render_error("Internal server error", :internal_server_error)
  end

  def show
    command_class = "#{@base_klass.name}::Show".constantize
    command = command_class.new(params, @base_klass, current_user, options)
    result = command.run

    render_json(result[:data], :ok, result[:meta_data])
  end

  def create
    command_class = "#{@base_klass.name}::Create".constantize
    command = command_class.new(params, @base_klass, current_user, options)
    result = command.run

    render_json(result[:data], :created, result[:meta_data])
  end

  def update
    command_class = "#{@base_klass.name}::Update".constantize
    command = command_class.new(params, @base_klass, current_user, options)
    result = command.run

    render_json(result[:data], :ok, result[:meta_data])
  end

  def destroy
    command_class = "#{@base_klass.name}::Destroy".constantize
    command = command_class.new(params, @base_klass, current_user, options)
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
    @options ||= {}
  end
end