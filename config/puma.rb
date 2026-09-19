# Configuration is available before Rails initialization and for direct Puma startup.
require_relative "application"

thread_count = Rails.application.config.x.concurrency.rails_max_threads
threads thread_count, thread_count
# Preserve the IPv4 listener with Puma 8's new IPv6 default.
port ENV.fetch("PORT", 3000), "0.0.0.0"
plugin :tmp_restart
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
