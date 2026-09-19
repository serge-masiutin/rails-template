class ApplicationJob < ActiveJob::Base
  include RequestCorrelatedJob

  # Queue хранится отдельно: задача должна видеть уже закоммиченные доменные записи.
  self.enqueue_after_transaction_commit = true
end
