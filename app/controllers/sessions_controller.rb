class SessionsController < ApplicationController
  # Вход проверяет пароль; выход отзывает только текущую сессию из подписанной cookie.
  skip_verify_authorized
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, status: :see_other, alert: "Повторите попытку позже." }

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params.expect(:email_address), password: params.expect(:password))
      start_new_session_for user
      redirect_to after_authentication_url, status: :see_other
    else
      flash.now[:alert] = "Неверный email или пароль."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
