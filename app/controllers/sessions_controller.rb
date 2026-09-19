class SessionsController < ApplicationController
  # Sign-in checks the password; sign-out revokes only the session in the signed cookie.
  skip_verify_authorized
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, status: :see_other, alert: t("auth.rate_limited") }

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params.expect(:email_address), password: params.expect(:password))
      start_new_session_for user
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
end
