class BaseCommand
  include ParamsValidator
  attr_accessor :params, :klass, :user
  
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
  def raise_bad_request_error(error_message, status_code = 422)
    raise CommandError.new({message: error_message, status_code: status_code})
  end

end