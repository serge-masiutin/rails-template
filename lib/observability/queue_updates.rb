module Observability
  # Bulk SQL bypasses model callbacks, so notifications cover those operations.
  module QueueUpdates
    def self.after_commit(_record)
      Realtime::OperationsUpdates.publish("queue")
    end

    def self.committed_change
      SolidQueue::Record.connection_pool.with_connection do |connection|
        AfterCommitEverywhere.after_commit(connection: connection) { Realtime::OperationsUpdates.publish("queue") }
      end
    end

    def self.notification(event)
      return if event.payload[:exception]

      if event.name == "enqueue_all.active_job"
        committed_change if event.payload.fetch(:adapter).is_a?(ActiveJob::QueueAdapters::SolidQueueAdapter) && event.payload.fetch(:enqueued_count).positive?
      elsif event.payload.fetch(:size).positive?
        committed_change
      end
    end
  end
end
