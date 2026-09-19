# Хранит только очищенный контракт AgentPrism; исходные SDK traces сюда не попадают.
class AgentTrace < ApplicationRecord
  RETENTION = 7.days
  PAGE_SIZE = 20

  scope :retained, -> { where(started_at: RETENTION.ago..) }

  def self.prune
    where(started_at: ...RETENTION.ago).in_batches.delete_all
  end
end
