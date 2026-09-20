RubyLLM.configure do |config|
  # Configure the shared SDK only during process boot.
  settings = Rails.configuration.x.llm
  config.public_send("#{settings.provider_key}=", settings.api_key) if settings.configured?
  config.default_model = nil
  config.request_timeout = settings.request_timeout
  config.max_retries = 0
  config.auto_upload_large_files = false
  config.log_stream_debug = false
  # SDK debug logging exposes prompts and responses; do not inherit RAILS_LOG_LEVEL.
  config.logger = SemanticLogger["RubyLLM"].tap { |logger| logger.level = :warn }
end
