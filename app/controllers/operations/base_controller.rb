module Operations
  class BaseController < ActionController::Base
    before_action :authenticate_operator
    before_action :disable_caching

    private

    def authenticate_operator
      credentials = Rails.application.config.x.operations
      return head :unauthorized unless credentials.configured?

      http_basic_authenticate_or_request_with(name: credentials.username, password: credentials.password)
    end

    def disable_caching
      response.headers["Cache-Control"] = "no-store"
    end
  end
end
