class LlmConfig < Anyway::Config
  PROVIDER_KEYS = { "openai" => :openai_api_key, "anthropic" => :anthropic_api_key, "gemini" => :gemini_api_key }.freeze

  attr_config :api_key, provider: "gemini", model: "gemini-3.8-flash", request_timeout: 30
  coerce_types request_timeout: :integer

  on_load do
    raise_validation_error("provider: expected openai, anthropic, or gemini") unless PROVIDER_KEYS.key?(provider)
    raise_validation_error("model must be set") if model.blank?
    unless (1..300).cover?(request_timeout)
      raise_validation_error("request_timeout: expected 1..300 seconds")
    end
  end

  def configured?
    api_key.present?
  end

  def ensure_configured!
    raise_validation_error("Set api_key in config/llm.local.yml or LLM_API_KEY") unless configured?
  end

  def provider_key
    PROVIDER_KEYS.fetch(provider)
  end
end
