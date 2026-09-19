require Rails.root.join("lib/observability/error_subscriber")
Rails.error.subscribe(Observability::ErrorSubscriber.new)

# Yabeda Rails hooks into server automatically; runner and tests need explicit setup.
Yabeda::Rails.install! unless defined?(Rails::Server) || defined?(Puma::CLI) || defined?(Unicorn::Launcher) || defined?(PhusionPassenger)
Yabeda::Rails.config.ignore_actions = [ /\AAdmin::/, /\AOperations::/, /\AMissionControl::/, "Rails::HealthController#show" ]

Yabeda.configure do
  group :starterapp do
    gauge :queue_jobs, tags: [ :state ], comment: "Solid Queue jobs by state"
    gauge :queue_processes, tags: [ :kind ], comment: "Solid Queue processes with a current heartbeat"
    gauge :queue_oldest_ready_age_seconds, comment: "Age of the oldest Ready job"
    counter :agent_trace_failures, tags: [ :stage ], comment: "Active Agent trace persistence failures"
    counter :agent_generations, tags: %i[agent action status], comment: "Completed Active Agent generations"
    histogram :agent_generation_duration_seconds, tags: %i[agent action status],
      buckets: [ 0.1, 0.5, 1, 5, 15, 30, 60, 120, 300 ], comment: "Active Agent generation duration"
    counter :agent_tokens, tags: %i[agent action direction], comment: "Provider-reported Active Agent tokens"
  end

  collect do
    snapshot = Operations::QueueSnapshot.capture
    snapshot.fetch(:jobs).each { |state, count| starterapp.queue_jobs.set({ state: state }, count) }
    snapshot.fetch(:processes).each { |kind, count| starterapp.queue_processes.set({ kind: kind }, count) }
    starterapp.queue_oldest_ready_age_seconds.set({}, snapshot.fetch(:oldest_ready_age_seconds))
  end
end

Rails.application.config.after_initialize do
  # An initial zero sample allows alerts to detect the first persistence failure.
  %w[storage sdk].each { |stage| Yabeda.starterapp.agent_trace_failures.increment({ stage: stage }, by: 0) }
end
