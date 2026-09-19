module Observability
  class AgentTelemetryLogger
    # The SDK interpolates exception.message; reject source content at the log boundary.
    def error(_message)
      Yabeda.starterapp.agent_trace_failures.increment(stage: "sdk")
      Rails.logger.error(event: "agent.trace_failed", stage: "sdk")
    end
  end
end
