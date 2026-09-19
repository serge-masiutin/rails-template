module Operations
  class HealthSnapshot
    def self.capture
      ApplicationRecord.connection_pool.with_connection { |connection| connection.select_value("SELECT 1") }
      snapshot = QueueSnapshot.capture
      required = Rails.env.production? ? %i[worker dispatcher scheduler] : %i[worker dispatcher]
      healthy = required.all? { |kind| snapshot.fetch(:processes).fetch(kind.to_s).positive? }
      { healthy: healthy, queue: snapshot }
    rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid => error
      Rails.logger.error(message: "Database health check failed", exception: error)
      { healthy: false, error: "database_unavailable" }
    end
  end
end
