module JsonHandler
  def render_json(klass=nil, result=nil, status=:ok)
    if result.present?
      data = result[:data].present? ? serialize_data(result[:data], klass) : serialize_data(result, klass)
      meta = result[:meta_data] if result[:meta_data].present?
      message = result[:message] if result[:message].present?
    end

    if meta.present?
      render json: { data: data, meta_data: meta, message: message }, status: status
    else
      render json: { data: data, message: message }, status: status
    end
  end
  
  def render_error(errors, status=:unprocessable_entity)
    render json: {errors: base_errors(errors)}, status: status
  end

  def base_errors(errors)
    if errors.is_a?(ActiveModel::Errors)
      errors.full_messages
    else
      errors
    end
  end

  def serialize_data(data, klass = nil) 
    if klass.present? && data.is_a?(klass)
      serializer = serializer_klass(klass)
      includes = serializer.try(:_reflections)&.keys # include associations if any, without N+1
      data = data.includes(includes) if includes.present? && data.respond_to?(:includes)
      ActiveModelSerializers::SerializableResource.new(data, each_serializer: serializer).as_json
    else
      ActiveModelSerializers::SerializableResource.new(data).as_json
    end
  end

  def serializer_klass(klass)
    "#{klass}Serializer".constantize
  end
  
end