require "active_agent/providers/ruby_llm_provider"

# Active Agent 1.6 uses RubyLLM 1.x request, tool, and usage interfaces.
class ActiveAgent::RubyLlmAdapter < ActiveAgent::Providers::RubyLLMProvider
  ToolDefinition = Data.define(:name, :description, :parameters_schema) do
    def provider_options = {}
  end

  def self.namespace = ActiveAgent::Providers::RubyLLM

  private

  def api_prompt_execute(parameters)
    model_id = parameters[:model] || options.model
    resolve_ruby_llm_provider!(model_id)
    arguments = { model: @ruby_llm_model, tools: build_ruby_llm_tools(parameters[:tools]) || {},
      temperature: parameters[:temperature], max_output_tokens: parameters[:max_tokens] || options.max_tokens,
      schema: response_schema(parameters[:response_format]) }
    messages = build_ruby_llm_messages(parameters)
    if parameters[:stream]
      @ruby_llm_provider.complete(messages, **arguments, &parameters.fetch(:stream))
      nil
    else
      response = @ruby_llm_provider.complete(messages, **arguments)
      normalize_ruby_llm_response(response, model_id)
    end
  end

  def response_schema(format)
    return unless format

    format = format.deep_symbolize_keys
    raise ArgumentError, "response_format must use json_schema" unless format.fetch(:type) == "json_schema"

    format.fetch(:json_schema).tap { |definition| definition.fetch(:schema) }
  end

  def convert_tool_calls_for_ruby_llm(tool_calls)
    tool_calls.to_h do |call|
      function = call.fetch(:function)
      arguments = function.fetch(:arguments)
      arguments = JSON.parse(arguments) if arguments.is_a?(String)
      [ call.fetch(:id), ::RubyLLM::ToolCall.new(id: call.fetch(:id), name: function.fetch(:name),
        arguments: arguments, thought_signature: call[:thought_signature]) ]
    end
  end

  def build_ruby_llm_tools(tools)
    definitions = super
    return unless definitions

    definitions.transform_values do |tool|
      ToolDefinition.new(name: tool.name, description: tool.description,
        parameters_schema: tool.parameters.deep_stringify_keys)
    end
  end

  def normalize_ruby_llm_response(response, model_id)
    normalized = super
    tokens = response.tokens
    usage = { input_tokens: tokens.input, output_tokens: tokens.output,
      cached_tokens: tokens.cache_read, cache_creation_tokens: tokens.cache_write,
      reasoning_tokens: tokens.thinking }.compact
    normalized[:usage] = usage if usage.any?
    if options.platform.to_s == "gemini" && response.raw.body["usageMetadata"].nil?
      normalized.delete(:usage)
    end
    normalized[:tool_calls]&.each do |call|
      call[:thought_signature] = response.tool_calls.fetch(call.fetch(:id)).thought_signature
    end
    normalized[:stop_reason] = response.finish_reason&.to_s
    normalized
  end
end
