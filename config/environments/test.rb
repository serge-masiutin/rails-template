Rails.application.configure do
  # Only the Go integration suite waits for real WebSocket subscriptions.
  config.turbo.test_connect_after_actions = ENV["ANYCABLE_SYSTEM_TEST"] == "1" ? [ :visit ] : []

  config.enable_reloading = false
  config.solid_queue.connects_to = { database: { writing: :queue } }

  config.eager_load = ENV["CI"].present?

  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  config.consider_all_requests_local = true
  # Rate limiting needs real cache counters in tests.
  config.cache_store = :memory_store

  config.action_dispatch.show_exceptions = :rescuable

  config.action_controller.allow_forgery_protection = false

  config.active_storage.service = :test

  config.action_mailer.delivery_method = :test

  config.action_mailer.default_url_options = { host: "example.com" }

  config.active_support.deprecation = :stderr

  config.action_controller.raise_on_missing_callback_actions = true
end
