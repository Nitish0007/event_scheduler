class CreateCommand < BaseCommand

  def run
    begin
      validate_params(@params, @klass)
      resource = @klass.new(@params)
      if resource.save
        # Reload the resource to get updated value after after_commit callbacks
        resource.reload
        return { data: resource }
      else
        raise_bad_request_error(resource.errors.full_messages.join(", "), :unprocessable_entity)
      end
    rescue BaseCommand::CommandError => e
      raise e
    rescue => e
      raise e
    end
  end

end