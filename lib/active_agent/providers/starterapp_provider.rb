require "active_agent/providers/ruby_llm_provider"

module ActiveAgent
  module Providers
    # A separate provider preserves standard transport and RubyLLM 2 token APIs.
    # Remove once upstream supports RubyLLM 2 usage, finish_reason and tool contracts.
    class StarterappProvider < RubyLLMProvider
      ToolDefinition = Data.define(:name, :description, :parameters_schema) do
        def provider_options = {}
      end

      def self.namespace = RubyLLM

      private

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
        normalized[:stop_reason] = response.finish_reason&.to_s
        normalized
      end
    end
  end
end
