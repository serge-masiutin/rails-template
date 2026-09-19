RubyLLM.configure do |config|
  # Active Agent использует конфигурацию SDK; меняем её только при загрузке процесса.
  settings = Rails.configuration.x.llm
  config.public_send("#{settings.provider_key}=", settings.api_key) if settings.configured?
  config.default_model = nil
  config.request_timeout = settings.request_timeout
  config.max_retries = 0
  config.auto_upload_large_files = false
  config.log_stream_debug = false
  # Уровень изолирован от RAILS_LOG_LEVEL: debug SDK раскрывает промпты и ответы.
  config.logger = SemanticLogger["RubyLLM"].tap { |logger| logger.level = :warn }
end
