require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
# Isolator selects its HTTP adapter at load time, after WebMock in tests.
require "isolator" if Rails.env.development? || Rails.env.test?
# Rails Semantic Logger needs this subscriber before lazy loading runs.
require "active_job/log_subscriber"
require_relative "../app/configs/web_config"
require_relative "../app/configs/operations_config"
require_relative "../app/configs/llm_config"
require_relative "../app/configs/concurrency_config"
require_relative "../lib/observability/json_formatter"
require_relative "../lib/observability/log_filter"
require_relative "../lib/observability/local_log"
require_relative "../lib/realtime/operations_updates"

module StarterApp
  class Application < Rails::Application
    config.load_defaults 8.1
    # Add tests for behavior and risk rather than every generated file.
    config.generators do |generators|
      generators.test_framework nil
      generators.system_tests nil
    end
    config.x.web = WebConfig.new
    config.x.operations = OperationsConfig.new
    config.x.llm = LlmConfig.new
    config.x.concurrency = ConcurrencyConfig.new
    # Puma and Solid Queue execute application code in threads; Current uses the same boundary.
    config.active_support.isolation_level = :thread
    config.active_job.log_arguments = false
    config.active_agent.show_previews = false
    config.mission_control.jobs.adapters = [ :solid_queue ]
    config.mission_control.jobs.base_controller_class = "Admin::BaseController"
    config.mission_control.jobs.http_basic_auth_enabled = false
    config.log_tags = { request_id: :request_id }
    config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
    config.semantic_logger.application = "StarterApp"
    config.semantic_logger.environment = Rails.env
    config.rails_semantic_logger.started = false
    config.rails_semantic_logger.processing = false
    config.rails_semantic_logger.rendered = false
    config.rails_semantic_logger.appenders do |appenders|
      if Rails.env.production?
        appenders.add(io: $stdout, formatter: Observability::JsonFormatter.new, filter: Observability::LogFilter)
      else
        appenders.add(logger: Observability::LocalLog.build(directory: Rails.root.join("log"), environment: Rails.env),
          formatter: Observability::JsonFormatter.new, filter: Observability::LogFilter)
        appenders.add(io: $stdout, formatter: Observability::JsonFormatter.new, filter: Observability::LogFilter) unless Rails.env.test?
      end
    end
    config.action_mailer.default_url_options = config.x.web.url_options
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en]
    config.i18n.fallbacks = false
    config.i18n.raise_on_missing_translations = true

    # The publisher owns a process-wide thread pool and must survive Rails reloads.
    config.autoload_lib(ignore: %w[assets tasks realtime/operations_updates.rb])
  end
end
