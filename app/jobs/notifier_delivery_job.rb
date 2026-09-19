class NotifierDeliveryJob < AbstractNotifier::AsyncAdapters::ActiveJob::DeliveryJob
  include RequestCorrelatedJob
  self.enqueue_after_transaction_commit = true
end
