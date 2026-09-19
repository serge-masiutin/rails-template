module Observability
  class AgentTelemetryLogger
    # SDK включает exception.message в строку; исходный текст не принимаем в журнал.
    def error(_message)
      Yabeda.starterapp.agent_trace_failures.increment(stage: "sdk")
      Rails.logger.error(event: "agent.trace_failed", stage: "sdk")
    end
  end
end
