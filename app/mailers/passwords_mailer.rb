class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Восстановление пароля StarterApp", to: user.email_address
  end
end
