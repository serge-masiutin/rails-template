class PasswordsController < ApplicationController
  allow_unauthenticated_access
  # Доступ к смене пароля проверяется подписанным токеном, привязанным к password_digest.
  skip_verify_authorized
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, status: :see_other, alert: "Повторите попытку позже." }

  def new
  end

  def create
    if user = User.find_by(email_address: params.expect(:email_address))
      PasswordsDelivery.reset(user).deliver_later
    end

    redirect_to new_session_path, status: :see_other, notice: "Если аккаунт существует, инструкция отправлена на почту."
  end

  def edit
  end

  def update
    if @user.reset_password(password: params.expect(:password), password_confirmation: params.expect(:password_confirmation))
      redirect_to new_session_path, status: :see_other, notice: "Пароль изменён."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, status: :see_other, alert: "Ссылка недействительна или срок её действия истёк."
    end
end
