class ApplicationJob < ActiveJob::Base
  include RequestCorrelatedJob

  # The queue is stored separately; jobs must see committed domain records.
  self.enqueue_after_transaction_commit = true
end
