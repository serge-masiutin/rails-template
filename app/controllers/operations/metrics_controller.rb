module Operations
  class MetricsController < BaseController
    def show
      Yabeda.collect!
      render plain: Prometheus::Client::Formats::Text.marshal(Yabeda::Prometheus.registry),
        content_type: Prometheus::Client::Formats::Text::CONTENT_TYPE
    end

    def workers
      # Снимок очереди собирает web; здесь нужны только счётчики, изменяемые worker.
      registry = Prometheus::Client::Registry.new
      %i[starterapp_agent_generations starterapp_agent_generation_duration_seconds starterapp_agent_tokens starterapp_agent_trace_failures].each do |name|
        registry.register(Yabeda::Prometheus.registry.get(name))
      end
      render plain: Prometheus::Client::Formats::Text.marshal(registry),
        content_type: Prometheus::Client::Formats::Text::CONTENT_TYPE
    end

    private

    def authenticate_operator
      config = Rails.application.config.x.operations
      return head :unauthorized unless config.metrics_configured?

      authenticate_or_request_with_http_token do |token, _options|
        ActiveSupport::SecurityUtils.secure_compare(token, config.metrics_token)
      end
    end
  end
end
