class PasswordsController < ApplicationController
  allow_unauthenticated_access
  # The signed reset token authorizes access and is bound to password_digest.
  skip_verify_authorized
  before_action :require_html_response
  before_action :set_user_by_token, only: :edit
  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :invalid_reset_token
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, status: :see_other, alert: t("auth.rate_limited") }

  def new
  end

  def create
    if user = User.find_by(email_address: params.expect(:email_address))
      PasswordsDelivery.reset(user).deliver_later
    end

    redirect_to new_session_path, status: :see_other, notice: t("auth.reset_sent")
  end

  def edit
  end

  def update
    @user = User.reset_password(token: params.expect(:token),
      password: params.expect(:password), password_confirmation: params.expect(:password_confirmation))
    if @user.errors.empty?
      redirect_to new_session_path, status: :see_other, notice: t("auth.password_changed")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def require_html_response
      respond_to { |format| format.html }
    end

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params.expect(:token))
    end

    def invalid_reset_token
      redirect_to new_password_path, status: :see_other, alert: t("auth.invalid_reset_link")
    end
end
