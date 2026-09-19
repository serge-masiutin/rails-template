# Общая граница генерации: настройки, версия промпта, очередь и наблюдаемость.
class ApplicationAgent < ActiveAgent::Base
  abstract!

  self.generation_job = AgentGenerationJob
  self.generate_later_queue_name = :agents

  generate_with :starterapp,
    model: -> { Rails.configuration.x.llm.model },
    platform: -> { Rails.configuration.x.llm.provider }

  before_generation :validate_configuration
  around_prompt :observe_generation

  # Стандартный обработчик gem пишет exception.message, где может быть исходный текст.
  # Ошибка остаётся видимой в журнале задания и Solid Queue.
  def self.handle_exception(error)
    raise error
  end

  private

  def validate_configuration
    Rails.configuration.x.llm.ensure_configured!
    prompt_version
  end

  def prompt_version = self.class.const_get(:PROMPT_VERSION, false)

  def observe_generation
    metadata = { agent: self.class.name, action: action_name, prompt_version: prompt_version,
      provider: Rails.configuration.x.llm.provider, model: Rails.configuration.x.llm.model }
    span = ActiveAgent::Telemetry.tracer.current_span
    # У вызова с instrumentation: false SDK не создаёт span.
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
