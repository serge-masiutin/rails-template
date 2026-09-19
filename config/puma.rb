# Конфигурация доступна до инициализации приложения и при прямом запуске Puma.
require_relative "application"

thread_count = Rails.application.config.x.concurrency.rails_max_threads
threads thread_count, thread_count
# Сохраняем IPv4 listener при переходе на Puma 8 с новым IPv6 default.
port ENV.fetch("PORT", 3000), "0.0.0.0"
plugin :tmp_restart
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
