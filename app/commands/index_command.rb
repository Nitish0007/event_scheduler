class IndexCommand < BaseCommand
  def run
    begin
      validate_params(@params, @klass)

      resources = base_query
      resources = filter_resources(resources)
      resources = search_resources(resources)
      resources = paginate_resources(resources)
      # TODO: compare performance of include_resources and serializer
      # resources = include_resources(resources) # using serializer instead of this for now

      return {
        data: resources,
        meta_data: meta_data(resources)
      }
    rescue BaseCommand::CommandError => e
      raise e
    rescue => e
      raise e
    end
  end

  private
  def options
    @options ||= {}
  end

  def search_resources(resources)
    return resources if @options[:search_by].blank?
    
    search_by = @options[:search_by]
    # For fuzzy global search
    if search_by.is_a?(String)
      columns_to_search = @klass.columns.select {|c| [:text, :string].include?(c.type) }.map(&:name)
      search_query = columns_to_search.map { |c| "lower(#{c}) like :search_value" }.join(" OR ")
      resources = resources.where(search_query, search_value: "%#{search_by.downcase}%")
      return resources
    end

    # when search_by is a hash and needs to be searched by specific columns
    search_by = search_by.to_unsafe_h if search_by.is_a?(ActionController::Parameters)
    search_by.each do |key, value|
      column = @klass.columns_hash[key.to_s]
      next unless column

      case column.type
      when :string, :text
        resources = resources.where("lower(#{key}) like ?", "%#{value.downcase}%")
      when :datetime, :date
        begin
          datetime = DateTime.parse(value)
          resources = resources.where("#{key} >= ? AND #{key} < ?", datetime.beginning_of_day, datetime.end_of_day)
        rescue ArgumentError
          raise_bad_request_error("#{key} must be a valid datetime", :bad_request)
        end
      when :integer, :float, :decimal
          resources = resources.where(key => value.to_s)
      else
        raise_bad_request_error("search on #{column.type} is not supported", :bad_request)
      end
    end 
    resources
  rescue => e
    raise_bad_request_error("search_by must be a valid string or hash", :bad_request)
  end
end