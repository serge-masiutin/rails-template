# Install subscriptions once; reattach callback objects after Rails reload.
events = %w[claim dispatch_scheduled discard_all retry_all release_many_blocked prune_processes].map { |name| "#{name}.solid_queue" } + [ "enqueue_all.active_job" ]
events.each do |name|
  ActiveSupport::Notifications.subscribe(name) { |event| Operations::QueueUpdates.notification(event) }
end

Rails.application.config.to_prepare do
  [ SolidQueue::Job, SolidQueue::ClaimedExecution, SolidQueue::FailedExecution,
    SolidQueue::BlockedExecution, SolidQueue::Pause ].each do |model|
    model.after_commit Operations::QueueUpdates
  end
  SolidQueue::Process.after_commit Operations::QueueUpdates, on: %i[create destroy]
end
