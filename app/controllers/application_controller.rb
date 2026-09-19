class ApplicationController < ActionController::Base
  include Authentication
  include Localization
  authorize :user, through: -> { Current.user }
  verify_authorized
  rescue_from ActionPolicy::Unauthorized, with: -> { head :forbidden }
  before_action { Current.request_id = request.request_id }
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
