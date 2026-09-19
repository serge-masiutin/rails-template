module Observability
  # Successful machine probes remain visible in metrics; failures stay in logs.
  module LogFilter
    PROBE_CONTROLLERS = %w[Operations::MetricsController Operations::HealthController Rails::HealthController].freeze

    def self.call(log)
      return true unless log.level == :info
      return true unless log.metric == "rails.controller.process_action"
      return true unless PROBE_CONTROLLERS.include?(log.payload.fetch(:controller))

      log.exception.present? || log.payload[:exception_object].present? || !(200..299).cover?(log.payload.fetch(:status))
    end
  end
end
