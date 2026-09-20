class ApplicationController < ActionController::Base
  include Authentication
  include Localization
  authorize :user, through: -> { Current.user }
  verify_authorized
  rescue_from ActionPolicy::Unauthorized, with: -> { head :forbidden }
  before_action { Current.request_id = request.request_id }
  allow_browser versions: :modern

  stale_when_importmap_changes
end
