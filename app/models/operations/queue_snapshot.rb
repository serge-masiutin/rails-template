module Operations
  class QueueSnapshot
    PROCESS_KINDS = %w[Worker Dispatcher Scheduler].freeze

    def self.capture
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
