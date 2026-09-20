# Subscribe once; reinstall model callbacks after Rails reloads.
events = %w[claim dispatch_scheduled discard_all retry_all release_many_blocked prune_processes].map { |name| "#{name}.solid_queue" } + [ "enqueue_all.active_job" ]
events.each do |name|
  ActiveSupport::Notifications.subscribe(name) { |event| Observability::QueueUpdates.notification(event) }
end

Rails.application.config.to_prepare do
  [ SolidQueue::Job, SolidQueue::ClaimedExecution, SolidQueue::FailedExecution,
    SolidQueue::BlockedExecution, SolidQueue::Pause ].each do |model|
    model.after_commit Observability::QueueUpdates
  end
  SolidQueue::Process.after_commit Observability::QueueUpdates, on: %i[create destroy]
end

at_exit { Realtime::OperationsUpdates.shutdown }
