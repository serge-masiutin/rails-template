# Puma also reads this configuration before the Rails application boots.
require_relative "application"

thread_count = Rails.application.config.x.concurrency.rails_max_threads
threads thread_count, thread_count
# Retain IPv4 binding despite Puma 8's IPv6 default.
port ENV.fetch("PORT", 3000), "0.0.0.0"
plugin :tmp_restart
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
