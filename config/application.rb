require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# Isolator selects its HTTP adapter at load time; test must load WebMock first.
require "isolator" if Rails.env.development? || Rails.env.test?
# Load the subscriber before Rails Semantic Logger configuration, including lazy loading.
require "active_job/log_subscriber"
require_relative "../app/configs/web_config"
require_relative "../app/configs/operations_config"
require_relative "../app/configs/llm_config"
require_relative "../app/configs/concurrency_config"
require_relative "../lib/observability/json_formatter"
require_relative "../lib/observability/log_filter"
require_relative "../lib/observability/local_log"

module StarterApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1
    config.x.web = WebConfig.new
    config.x.operations = OperationsConfig.new
    config.x.llm = LlmConfig.new
    config.x.concurrency = ConcurrencyConfig.new
    # Puma and Solid Queue execute application code in threads; Current is thread-scoped.
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

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
