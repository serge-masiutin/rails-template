require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = :local
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false
  config.cache_store = :solid_cache_store
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  config.action_mailer.default_url_options = config.x.web.url_options
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]
  config.hosts = [ config.x.web.host ]
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Asset builds need no database or SMTP; runtime requires all secrets.
  unless ENV["SECRET_KEY_BASE_DUMMY"]
    raise "Set OPERATIONS_USERNAME, OPERATIONS_PASSWORD and OPERATIONS_METRICS_TOKEN" unless config.x.operations.configured? && config.x.operations.metrics_configured?
    %w[DB_HOST DB_PASSWORD SECRET_KEY_BASE SMTP_ADDRESS SMTP_USERNAME SMTP_PASSWORD MAIL_FROM].each do |key|
      raise KeyError, "Missing #{key}" if ENV.fetch(key).empty?
    end
    config.action_mailer.smtp_settings = {
      address: ENV.fetch("SMTP_ADDRESS"),
      port: Integer(ENV.fetch("SMTP_PORT", 587)),
      user_name: ENV.fetch("SMTP_USERNAME"),
      password: ENV.fetch("SMTP_PASSWORD"),
      authentication: :plain,
      enable_starttls: true
    }
  end
end
