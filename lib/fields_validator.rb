module FieldsValidator
  def validate_fields(params, klass)
    klass.columns.each do |column|
      next if params[column.name].nil?

      case column.type
      when :string
        raise_bad_request_error("#{column.name} must be a string", 422) unless valid_string?(params[column.name])
      when :integer
        raise_bad_request_error("#{column.name} must be an integer", 422) unless valid_integer?(params[column.name])
      when :boolean
        raise_bad_request_error("#{column.name} must be a boolean", 422) unless valid_boolean?(params[column.name])
      when :datetime
        raise_bad_request_error("#{column.name} must be a datetime", 422) unless valid_datetime?(params[column.name])
      when :json
        raise_bad_request_error("#{column.name} must be a json", 422) unless valid_json?(params[column.name])
      end
    end
  end

  def valid_string?(string)
    String(string)
    return true
  rescue false
  end

  def valid_integer?(integer)
    Integer(integer)
    return true
  rescue false
  end

  def valid_boolean?(boolean)
    return boolean.is_a?(TrueClass) || boolean.is_a?(FalseClass) || 
    (boolean.is_a?(String) && (boolean.downcase == "true" || boolean.downcase == "false"))
  rescue
    false
  end

  def valid_datetime?(datetime) 
    DateTime.parse(datetime)
    return true
  rescue
    false
  end

  def valid_json?(json)
    json = json.to_json
    !!JSON.parse(json)
    return true
  rescue
    false
  end
end