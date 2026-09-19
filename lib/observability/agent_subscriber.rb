module Observability
  class AgentSubscriber
    def call(event)
      payload = event.payload
      error = payload[:exception_object]
      labels = payload.slice(:agent, :action).merge(status: error ? "error" : "ok")
      seconds = event.duration / 1000.0

      Yabeda.starterapp.agent_generations.increment(labels)
      Yabeda.starterapp.agent_generation_duration_seconds.measure(labels, seconds)

      metadata = payload.slice(:agent, :action, :prompt_version, :provider, :model, :finish_reason)
        .merge(event: "agent.generated", status: labels.fetch(:status), duration_ms: event.duration.round(1))
      if (usage = payload[:usage])
        metadata[:usage] = {}
        %i[input output].each do |direction|
          count = usage.public_send("#{direction}_tokens")
          next if count.nil? # Some providers omit usage.

          Yabeda.starterapp.agent_tokens.increment(payload.slice(:agent, :action).merge(direction: direction), by: count)
          metadata[:usage][direction] = count
        end
      end

      SemanticLogger.named_tagged(request_id: Current.request_id) do
        Rails.logger.public_send(error ? :error : :info,
          message: "Active Agent generation", payload: metadata, exception: error)
      end
    end
  end
end
