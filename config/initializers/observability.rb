require Rails.root.join("lib/observability/error_subscriber")
Rails.error.subscribe(Observability::ErrorSubscriber.new)

# Yabeda Rails автоматически подключается к server; runner и tests подключаем явно.
Yabeda::Rails.install! unless defined?(Rails::Server) || defined?(Puma::CLI) || defined?(Unicorn::Launcher) || defined?(PhusionPassenger)
Yabeda::Rails.config.ignore_actions = [ /\AAdmin::/, /\AOperations::/, /\AMissionControl::/, "Rails::HealthController#show" ]

Yabeda.configure do
  group :starterapp do
    gauge :queue_jobs, tags: [ :state ], comment: "Число заданий Solid Queue по состояниям"
    gauge :queue_processes, tags: [ :kind ], comment: "Число процессов Solid Queue с актуальным heartbeat"
    gauge :queue_oldest_ready_age_seconds, comment: "Время ожидания самого старого готового задания"
    counter :agent_trace_failures, tags: [ :stage ], comment: "Сбои сохранения трасс Active Agent"
    counter :agent_generations, tags: %i[agent action status], comment: "Завершённые генерации Active Agent"
    histogram :agent_generation_duration_seconds, tags: %i[agent action status],
      buckets: [ 0.1, 0.5, 1, 5, 15, 30, 60, 120, 300 ], comment: "Длительность генерации Active Agent"
    counter :agent_tokens, tags: %i[agent action direction], comment: "Токены Active Agent, сообщённые провайдером"
  end

  collect do
    snapshot = Operations::QueueSnapshot.capture
    snapshot.fetch(:jobs).each { |state, count| starterapp.queue_jobs.set({ state: state }, count) }
    snapshot.fetch(:processes).each { |kind, count| starterapp.queue_processes.set({ kind: kind }, count) }
    starterapp.queue_oldest_ready_age_seconds.set({}, snapshot.fetch(:oldest_ready_age_seconds))
  end
end

Rails.application.config.after_initialize do
  # Нулевой первый sample позволяет alert увидеть первый сбой сохранения.
  %w[storage sdk].each { |stage| Yabeda.starterapp.agent_trace_failures.increment({ stage: stage }, by: 0) }
end
