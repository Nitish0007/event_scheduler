class BaseApiService
  keyword_init: true

  attr_accessor :api_key, :params

  def initialize(api_key, params)
    @api_key = api_key
    @params = params
  end

  def set_headers
    {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  def payload
    if @params[:payload].present?
      return @params[:payload].to_json
    end
    return nil
  end

  def get
    response = HTTParty.get(base_url, headers: set_headers)
    response.parsed_response
  end

  def post
    response = HTTParty.post(base_url, headers: set_headers, body: payload)
    response.parsed_response
  end
  
  def base_url
    raise NotImplementedError, 'Subclass must implement base_url'
  end

  private
  def validate_api_key
    raise 'API key is required' if @api_key.blank?
  end

  def validate_params(params)
    raise NotImplementedError, 'Subclass must implement validate_params'
  end
  
end