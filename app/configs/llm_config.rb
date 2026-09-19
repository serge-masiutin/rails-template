class LlmConfig < Anyway::Config
  PROVIDER_KEYS = { "openai" => :openai_api_key, "anthropic" => :anthropic_api_key, "gemini" => :gemini_api_key }.freeze

  attr_config :provider, :model, :api_key, request_timeout: 30
  coerce_types request_timeout: :integer

  on_load do
    if [ provider, model, api_key ].any?(&:present?)
      unless [ provider, model, api_key ].all?(&:present?)
        raise_validation_error("provider, model and api_key must be set together")
      end
      unless PROVIDER_KEYS.key?(provider)
        raise_validation_error("provider: expected openai, anthropic or gemini")
      end
    end
    unless (1..300).cover?(request_timeout)
      raise_validation_error("request_timeout: expected 1..300 seconds")
    end
  end

  def configured?
    provider.present?
  end

  def ensure_configured!
    raise_validation_error("Set LLM_PROVIDER, LLM_MODEL and LLM_API_KEY") unless configured?
  end

  def provider_key
    PROVIDER_KEYS.fetch(provider)
  end
end
