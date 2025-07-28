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

  def sort_resources(resources)
    sort_by = @options[:sort_by] || "updated_at"
    sort_order = @options[:sort_order] || :desc

    if !allowed_sort_by_columns.include?(sort_by) || !allowed_sort_orders.include?(sort_order)
      raise_bad_request_error("Invalid sort_by or sort_order", :bad_request)
    end

    resources = resources.order("#{sort_by} #{sort_order}")
    resources
  end

  def allowed_sort_orders
    [:asc, :desc]
  end
  
  def allowed_sort_by_columns
    @klass.columns_hash.keys.map(&:to_s)
  end

end