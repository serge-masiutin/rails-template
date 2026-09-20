module Observability
  module Health
    PROCESS_KINDS = %w[Worker Dispatcher Scheduler].freeze

    def self.capture
      ApplicationRecord.connection_pool.with_connection { |connection| connection.select_value("SELECT 1") }
      snapshot = queue_snapshot
      required = Rails.env.production? ? %i[worker dispatcher scheduler] : %i[worker dispatcher]
      healthy = required.all? { |kind| snapshot.fetch(:processes).fetch(kind.to_s).positive? }
      { healthy: healthy, queue: snapshot }
    rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid => error
      Rails.logger.error(message: "Database health check failed", exception: error)
      { healthy: false, error: "database_unavailable" }
    end

    def self.queue_snapshot
      live_processes = SolidQueue::Process.where(last_heartbeat_at: SolidQueue.process_alive_threshold.ago..).group(:kind).count
      {
        jobs: {
          ready: SolidQueue::ReadyExecution.count,
          scheduled: SolidQueue::ScheduledExecution.count,
          claimed: SolidQueue::ClaimedExecution.count,
          blocked: SolidQueue::BlockedExecution.count,
          failed: SolidQueue::FailedExecution.count
        },
        processes: PROCESS_KINDS.to_h { |kind| [ kind.downcase, live_processes.fetch(kind, 0) ] },
        oldest_ready_age_seconds: SolidQueue::ReadyExecution.minimum(:created_at).then { |at| at ? [ Time.current - at, 0 ].max.round : 0 }
      }
    end
  end
end
