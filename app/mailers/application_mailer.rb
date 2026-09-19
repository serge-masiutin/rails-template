class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "no-reply@starterapp.local")
  layout "mailer"
  self.delivery_job = MailDeliveryJob
end
