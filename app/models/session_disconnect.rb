class SessionDisconnect < ApplicationRecord
  # Primary-database outbox: only acknowledged disconnects remove their intent.
  def self.dispatch_pending
    Rails.logger.info(event: "sessions.disconnect_backlog", count: count,
      oldest_created_at: minimum(:created_at))
    find_each { |intent| break unless intent.enqueue }
  end

  def enqueue
    job = DisconnectSessionsJob.perform_later(session_ids, outbox_id: id)
    return true if job

    report_enqueue_failure(ActiveJob::EnqueueError.new("Session disconnect enqueue was aborted"))
  rescue SolidQueue::Job::EnqueueError, ActiveJob::EnqueueError => error
    report_enqueue_failure(error)
  end

  private

  def report_enqueue_failure(error)
    Rails.error.report(error, handled: true, severity: :error, source: "sessions.disconnect_enqueue",
      context: { outbox_id: id })
    false
  end
end
