class SessionsController < ApplicationController
  # Credentials authorize sign-in; the signed cookie identifies the session to revoke.
  skip_verify_authorized
  allow_unauthenticated_access only: %i[ new create ]
  before_action :require_html_response
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, status: :see_other, alert: t("auth.rate_limited") }

  def new
  end

  def create
    authenticated_session = User.authenticate_session(
      email_address: params.expect(:email_address), password: params.expect(:password),
      user_agent: request.user_agent, ip_address: request.remote_ip)
    if authenticated_session
      attach_session authenticated_session
      redirect_to after_authentication_url, status: :see_other
    else
      flash.now[:alert] = t("auth.invalid_credentials")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end

  private

  def require_html_response
    respond_to { |format| format.html }
  end
end
