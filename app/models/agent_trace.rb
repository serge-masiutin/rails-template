class AgentTrace < ApplicationRecord
  RETENTION = 7.days
  PAGE_SIZE = 20

  scope :retained, -> { where(started_at: RETENTION.ago..) }
  after_create_commit -> { Realtime::OperationsUpdates.publish("agents") }

  def self.prune
    where(started_at: ...RETENTION.ago).in_batches.delete_all.tap do |count|
      if count.positive?
        ActiveRecord.after_all_transactions_commit { Realtime::OperationsUpdates.publish("agents") }
      end
    end
  end
end
