class BaseCommand
  attr_accessor :params, :klass, :user, :options
  include ParamsValidator
  
  class CommandError < StandardError
    attr_accessor :error_message, :status_code

    def initialize(error)
      @error_message = error[:message]
      @status_code = error[:status_code]
    end
    
  end

  def initialize(params, klass, user, options = {})
    @params = params
    @klass = klass
    @user = user
    @options = options
  end

  def run
    raise NotImplementedError, "Subclasses must implement the run method"
  end

  private
  def raise_bad_request_error(error_message, status_code = :unprocessable_entity)
    raise BaseCommand::CommandError.new({message: error_message, status_code: status_code})
  end

  def base_query
    @klass.all
  end

  def filter_resources(resources)
    if @options[:filters].present?
      resources = resources.where(@options[:filters])
    end
    resources
  end

  def include_resources(resources)
    return resources if @options[:include].blank?
    resources = resources.includes(@options[:include])
    resources
  end

  def paginate_resources(resources)
    resources.page(@params[:page] || 1).per(@params[:per_page] || 10)
  end

  def meta_data(resources)
    {
      total_pages: resources.total_pages,
      total_count: resources.total_count,
      current_page: resources.current_page,
      per_page: resources.limit_value
    }
  end

end