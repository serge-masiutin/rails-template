class MailDeliveryJob < ActionMailer::MailDeliveryJob
  include RequestCorrelatedJob
  self.enqueue_after_transaction_commit = true
end
