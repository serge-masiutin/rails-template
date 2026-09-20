require Rails.root.join("lib/observability/error_subscriber")
Rails.error.subscribe(Observability::ErrorSubscriber.new)

# Yabeda Rails configures server processes automatically, but not runners or tests.
Yabeda::Rails.install! unless defined?(Rails::Server) || defined?(Puma::CLI) || defined?(Unicorn::Launcher) || defined?(PhusionPassenger)
Yabeda::Rails.config.ignore_actions = [ /\AAdmin::/, /\AOperations::/, /\AMissionControl::/, "Rails::HealthController#show" ]

Yabeda.configure do
  group :starterapp do
    gauge :queue_jobs, tags: [ :state ], comment: "Solid Queue jobs by state"
    gauge :queue_processes, tags: [ :kind ], comment: "Solid Queue processes with a recent heartbeat"
    gauge :queue_oldest_ready_age_seconds, comment: "Age of the oldest ready job"
    counter :agent_trace_failures, tags: [ :stage ], comment: "Active Agent trace storage failures"
    counter :agent_generations, tags: %i[agent action status], comment: "Completed Active Agent generations"
    histogram :agent_generation_duration_seconds, tags: %i[agent action status],
      buckets: [ 0.1, 0.5, 1, 5, 15, 30, 60, 120, 300 ], comment: "Active Agent generation duration"
    counter :agent_tokens, tags: %i[agent action direction], comment: "Active Agent tokens reported by the provider"
  end

  collect do
    snapshot = Observability::Health.queue_snapshot
    snapshot.fetch(:jobs).each { |state, count| starterapp.queue_jobs.set({ state: state }, count) }
    snapshot.fetch(:processes).each { |kind, count| starterapp.queue_processes.set({ kind: kind }, count) }
    starterapp.queue_oldest_ready_age_seconds.set({}, snapshot.fetch(:oldest_ready_age_seconds))
  end
end

Rails.application.config.after_initialize do
  # A zero baseline makes the first storage failure visible to the alert.
  %w[storage sdk].each { |stage| Yabeda.starterapp.agent_trace_failures.increment({ stage: stage }, by: 0) }
end
