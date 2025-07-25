class ApplicationController < ActionController::Base
	skip_forgery_protection if: -> { request.format.json? }
	# respond_to :json, :html, :turbo_stream
	
	before_action :validate_request_format
	before_action :authenticate_request!
	before_action :authenticate_user!
	skip_before_action :authenticate_user!, if: -> { is_api_request? || (controller_name == "dashboard" && action_name == "welcome") }
	
	helper_method :current_user
	helper_method :organizer_user?
	helper_method :customer_user?
	helper_method :is_api_request?

	# override devise's authenticate_user! method to rails-views requests and avoid in case of APIs requests
	def authenticate_user!
		super unless is_api_request?
	end

	def authenticate_request!
		# Only authenticate for v1 API requests
		return unless is_api_request?
		
		fetch_token_from_request
		if @token.nil?
			render json: { error: 'Unauthorized request' }, status: :unauthorized
			return
		else
			decoded = JwtToken.verify(@token)
			if decoded.nil? || (decoded.present? && decoded["id"].blank?) || (decoded.present? && decoded["id"].to_i != params[:user_id].to_i)
				return render json: { error: 'Invalid Token!' }, status: :unauthorized
			end
			@current_user = User.find_by(id: decoded["id"])
			unless @current_user.present?
				return render json: { error: "User not found" }, status: :unauthorized
			end
		end
	end
	
	def current_user
		# For API requests, @current_user is set in authenticate_request! and should not trigger Devise's authenticate_user!
		return @current_user if defined?(@current_user) && @current_user.present?
		# For non-API (Rails views) requests, fallback to Devise's current_user
		super unless is_api_request?
	end

	def organizer_user?
		@current_user.organizer?
	end

	def customer_user?
		@current_user.customer?
	end

	def allow_organizer_only
		if !organizer_user?
			render json: { message: "This action is protected, you don't have permission to perform this action" }, status: :unauthorized
		end
	end

	def allow_customer_only
		if !customer_user?
			render json: { message: "This action is protected, you don't have permission to perform this action" }, status: :unauthorized
		end
	end

	def is_api_request?
		request.path.start_with?('/api/v1')
	end

	protected
	def after_unauthenticated_path_for(resource_or_scope)
		welcome_path
	end

	private
	def validate_request_format
		if is_api_request? && !request.format.json?
			return render json: { error: 'Invalid request format. Please use JSON format' }, status: :bad_request
		end
	end

	def fetch_token_from_request
		auth_header = request.headers['Authorization']
		@token = nil
		if auth_header.present?
			@token = auth_header.split(" ").last
		end
	end

end
