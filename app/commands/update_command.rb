class UpdateCommand < BaseCommand
  def run
    begin
      resource = check_record_exists?(@klass, @params[:id])
      resource.assign_attributes(resource_params)
      resource = build_has_many_associations(resource)
      if resource.save
        # attach record to associations after successfull creation of current resource if ids are given in payload
        attach_association_ids(resource)
        # Reload the resource to get updated value after after_commit callbacks
        resource.reload
        return { data: resource }
      else
        raise_bad_request_error(resource.errors.full_messages.join(", "), :unprocessable_entity)
      end
    rescue BaseCommand::CommandError => e
      raise e.message
    rescue ActiveRecord::RecordInvalid => e
      raise_bad_request_error(e.message, :unprocessable_entity)
    rescue => e
      raise e.message
    end
  end

  private

  def check_record_exists? klass, id
    raise_bad_request_error("#{klass}: id or class name is missing", :not_found) if klass.blank? || id.blank?
    raise_bad_request_error("#{klass} record not found", :not_found) unless klass.exists?(id: id)
    klass.find_by_id(id)
  end

  def build_has_many_associations(resource)
    @klass.reflect_on_all_associations.each do |association|
      if association.macro == :has_many && @association_params[association.name].present?
        associated_records = @association_params[association.name].map do |param|
          association.klass.new(param.permit(*permitted_attributes(association.klass)))
        end
        resource.send("#{association.name}=", associated_records)
      end
    end
    resource
  end

  def attach_association_ids(resource)
    @klass.reflect_on_all_associations.each do |association|
      ids_key = :"#{association.name.to_s.singularize}_ids"
      if @params[ids_key].present?
        resource.send("#{ids_key}=", @params[ids_key])
      end
    end
    resource
  end

  def resource_params
    validate_fields(@params, @klass)
    resource_name = @klass.name.underscore.to_sym
    # Use the controller's strong parameters pattern
    if @params[resource_name].present?
      @resource_params ||= @params.require(resource_name).permit(*permitted_params)
    else
      # Fallback if no nested params
      @resource_params ||= @params.permit(*permitted_params)
    end
    
    # Store association params separately for later processing
    @association_params = extract_association_params
    @resource_params
  end

  # this method extract associations params from payload
  def extract_association_params
    return {} unless @params.respond_to?(:require)
    
    resource_name = @klass.name.underscore.to_sym
    return {} unless @params[resource_name].present?
    
    association_params = {}
    @klass.reflect_on_all_associations.each do |association|
      if @params[resource_name][association.name].present?
        association_params[association.name] = @params[resource_name][association.name]
      end
    end
    
    association_params
  end

  def permitted_params
    permitted = permitted_attributes(@klass)

    # allowed nested params for has_many associations with 'accepts_nested_attributes_for' used in model
    @klass.reflect_on_all_associations(:has_many).each do |assoc|
      nested_fields = permitted_attributes(assoc.klass)
      if assoc.klass.nested_attributes_options.include?(assoc.name)
        nested_fields += [:id, :_destroy]
        permitted << { "#{assoc.name}_attributes".to_sym => nested_fields }
      else
        permitted << assoc.name.to_sym
      end
    end
  
    permitted
  end

  def permitted_attributes klass=@klass
    @klass.column_names.map(&:to_sym)
  end
end
