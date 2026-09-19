module Admin
  class BaseController < ApplicationController
    prepend_before_action :disable_caching
    before_action :authorize_administrator
    rescue_from ActionPolicy::Unauthorized, with: :deny_access
    layout "admin"

    private

    def authorize_administrator
      authorize! :admin, to: :access?
    end

    def disable_caching
      response.headers["Cache-Control"] = "no-store"
      response.headers["Referrer-Policy"] = "same-origin"
    end

    def deny_access
      respond_to do |format|
        format.html { render "admin/access_denied", layout: "application", status: :forbidden }
        format.any { head :forbidden }
      end
    end

    def request_authentication
      request.format.json? ? head(:unauthorized) : super
    end
  end
end
