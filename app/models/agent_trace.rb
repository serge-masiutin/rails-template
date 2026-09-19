# Store only the sanitized AgentPrism contract, never raw SDK traces.
class AgentTrace < ApplicationRecord
  RETENTION = 7.days
  PAGE_SIZE = 20

  scope :retained, -> { where(started_at: RETENTION.ago..) }
  after_create_commit -> { Operations::Updates.publish("agents") }

  def self.prune
    where(started_at: ...RETENTION.ago).in_batches.delete_all.tap do |count|
      if count.positive?
        ActiveRecord.after_all_transactions_commit { Operations::Updates.publish("agents") }
      end
    end
  end
end
