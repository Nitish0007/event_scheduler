class IndexCommand < BaseCommand
  def run
    validate_params(@params, @klass)
    resources = @klass.page(@params[:page] || 1).per(@params[:per_page] || 10)
    {
      data: resources,
      meta_data: {
        total_pages: resources.total_pages,
        total_count: resources.total_count,
        current_page: resources.current_page,
        per_page: resources.limit_value
      }
    }
  end
end