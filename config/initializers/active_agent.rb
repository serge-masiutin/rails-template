require Rails.root.join("lib/observability/agent_subscriber")
require Rails.root.join("lib/active_agent/providers/starterapp_provider")

ActiveSupport.on_load(:active_agent) do
  # The built-in debug subscriber may log provider error content.
  ActiveAgent::Providers::LogSubscriber.detach_from :active_agent
  ActiveAgent::Providers::LogSubscriber.detach_from :"provider.active_agent"
end

ActiveSupport::Notifications.subscribe("generate.starterapp_agent", Observability::AgentSubscriber.new)

require Rails.root.join("lib/observability/agent_telemetry_logger")
ActiveAgent::Telemetry.configure do |config|
  config.enabled = true
  config.capture_bodies = false
  config.local_storage = false
  config.endpoint = nil
  config.api_key = nil
  config.batch_size = 1
  config.async = false
  config.logger = Observability::AgentTelemetryLogger.new
  config.local_store = ->(trace, sdk) { AgentTrace::Capture.call(trace, sdk) }
end
