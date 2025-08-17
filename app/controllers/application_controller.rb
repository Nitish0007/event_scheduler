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
	helper_method :api_auth_token

	# override devise's authenticate_user! method to rails-views requests and avoid in case of APIs requests
	def authenticate_user!
		super unless is_api_request?
	end


	def api_auth_token
		token = RedisCache.get("api_auth_token_#{@current_user.id}")
		if token.present?
			return token
		end

		return nil unless @current_user
		
		payload = {
			id: @current_user.id,
			email: @current_user.email,
			role: @current_user.role
		}
		token = JwtToken.generate(payload, 10.minutes.from_now)
		RedisCache.set("api_auth_token_#{@current_user.id}", token, expires_in: 10.minutes.to_i)
		token
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
		current_user.organizer?
	end

	def customer_user?
		current_user.customer?
	end

	def allow_organizer_only
		if !organizer_user?
			flash[:alert] = "This action is protected, you don't have permission to perform this action"
			if is_api_request?
				render json: { message: "This action is protected, you don't have permission to perform this action" }, status: :unauthorized
			else
				redirect_to dashboard_path
			end
		end
	end

	def allow_customer_only
		if !customer_user?
			flash[:alert] = "This action is protected, you don't have permission to perform this action"
			if is_api_request?
				render json: { message: "This action is protected, you don't have permission to perform this action" }, status: :unauthorized
			else
				redirect_to dashboard_path
			end
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
