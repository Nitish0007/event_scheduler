class CreateCommand < BaseCommand

  def run
    begin
      resource = @klass.new(resource_params)
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
      raise e
    rescue ActiveRecord::RecordInvalid => e
      raise_bad_request_error(e.message, :unprocessable_entity)
    rescue => e
      raise e
    end
  end

  private

  def check_associated_records_exists?
    # check_associated_records_exists? is a hash with association_name as key and association_id as value
    # this methods is used to check any resouce that must present before creation of current resource
    return if @options[:check_associated_records_exists?].blank?

    associations_hash = @options[:check_associated_records_exists?]

    associations_hash.each do |association_name, association_id|
      next if associated_record_exists?(association_name, association_id)
      raise_bad_request_error("#{association_name.to_s.humanize} does not exist", :unprocessable_entity)
    end
  end

  def associated_record_exists? association_name, association_id
    return false if association_id.blank?
    begin
      association_klass = association_name.to_s.classify.safe_constantize
      return false if association_klass.blank?
      association_klass.exists?(id: association_id)
    rescue NameError => e
      Rails.logger.error("Error in check_associated_records_exists?: #{e.message}")
      return false
    end
  end

  def build_has_many_associations(resource)
    @klass.reflect_on_all_associations.each do |association|
      if association.macro == :has_many && @association_params[association.name].present?
        associated_records = @association_params[association.name].map do |param|
          # Keeping it simple: not handling nested associations here
          permitted_association_param = param.permit(*permitted_attributes(association.klass))
          association.klass.new(permitted_association_param)
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
      if @klass.nested_attributes_options.include?(assoc.name)
        permitted << { "#{assoc.name}_attributes".to_sym => nested_fields }
      else
        permitted << assoc.name.to_sym
      end
    end
  
    permitted
  end

  def permitted_attributes klass=@klass
    klass.column_names.map(&:to_sym)
  end

end