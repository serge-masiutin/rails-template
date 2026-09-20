module Observability
  class AgentTelemetryLogger
    # SDK messages embed exception.message, which may contain private provider data.
    def error(_message)
      Yabeda.starterapp.agent_trace_failures.increment(stage: "sdk")
      Rails.logger.error(event: "agent.trace_failed", stage: "sdk")
    end
  end
end
