class PasswordsDelivery < ApplicationDelivery
  mailer "PasswordsMailer"
  delivers :reset
end
