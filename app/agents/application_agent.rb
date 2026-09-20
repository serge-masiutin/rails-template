class ApplicationAgent < ActiveAgent::Base
  abstract!

  self.generation_job = AgentGenerationJob
  self.generate_later_queue_name = :agents

  def self.provider_load(service_name)
    provider_class = super
    provider_class == ActiveAgent::Providers::RubyLLMProvider ? ActiveAgent::RubyLlmAdapter : provider_class
  end

  generate_with :ruby_llm,
    model: -> { Rails.configuration.x.llm.model },
    platform: -> { Rails.configuration.x.llm.provider }

  before_generation :validate_configuration
  around_prompt :observe_generation

  # The default handler logs exception.message, which can contain private input.
  # Job logs and Solid Queue still record the failure.
  def self.handle_exception(error)
    raise error
  end

  private

  def validate_configuration
    Rails.configuration.x.llm.ensure_configured!
    prompt_version
  end

  def prompt_version = self.class.const_get(:PROMPT_VERSION, false)

  def process_prompt_templates_response_format(response_format)
    format = response_format.is_a?(Hash) ? response_format : { type: response_format.to_s }
    return super unless format.fetch(:type).to_s == "json_schema"

    # Active Agent camelizes property names without updating required or $ref.
    format.merge(json_schema: prompt_view_schema(format[:json_schema]))
  end

  def observe_generation
    metadata = { agent: self.class.name, action: action_name, prompt_version: prompt_version,
      provider: Rails.configuration.x.llm.provider, model: Rails.configuration.x.llm.model }
    span = ActiveAgent::Telemetry.tracer.current_span
    # The SDK omits spans when instrumentation is disabled.
    if span
      metadata.except(:agent, :action).each { |key, value| span.set_attribute("starterapp.#{key}", value) }
      span.set_attribute("starterapp.request_id", Current.request_id) if Current.request_id
      job_id = SemanticLogger.named_tags[:job_id]
      span.set_attribute("starterapp.job_id", job_id) if job_id
    end
    ActiveSupport::Notifications.instrument("generate.starterapp_agent", metadata) do |payload|
      response = yield
      payload[:usage] = response.usage
      payload[:finish_reason] = response.finish_reason
      if span && response.usage
        usage = { input: response.usage.input_tokens, output: response.usage.output_tokens,
          cached: response.usage.cached_tokens, cache_creation: response.usage.cache_creation_tokens,
          reasoning: response.usage.reasoning_tokens }.compact
        usage.each { |key, value| span.set_attribute("starterapp.usage.#{key}", value) }
        span.children.select { |child| child.type == "llm" }.each do |child|
          usage.each { |key, value| child.set_attribute("starterapp.usage.#{key}", value) }
        end
      end
      response
    end
  end
end
