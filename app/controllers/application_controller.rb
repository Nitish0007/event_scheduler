class ApplicationController < ActionController::Base
	skip_forgery_protection if: -> { request.format.json? }
	respond_to :json
end
