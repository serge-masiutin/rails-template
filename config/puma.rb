# Конфигурация доступна до инициализации приложения и при прямом запуске Puma.
require_relative "application"

thread_count = Rails.application.config.x.concurrency.rails_max_threads
threads thread_count, thread_count
port ENV.fetch("PORT", 3000)
plugin :tmp_restart
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
