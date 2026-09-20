class ApplicationJob < ActiveJob::Base
  include RequestCorrelatedJob

  # The queue uses a separate database; jobs must see committed domain records.
  self.enqueue_after_transaction_commit = true
end
