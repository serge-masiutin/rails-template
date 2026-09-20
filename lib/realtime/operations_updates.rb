require "concurrent"
require "set"

module Realtime
  class OperationsUpdates
    STREAM = "operations:updates"

    def initialize
      @executor = Concurrent::ThreadPoolExecutor.new(min_threads: 0, max_threads: 1,
        max_queue: 64, fallback_policy: :abort, auto_terminate: false, name: "operations-updates")
      @mutex = Mutex.new
      @pending = Set.new
      @pid = Process.pid
    end

    def publish(topic, stream: STREAM)
      key = [ stream, topic ]
      @mutex.synchronize do
        if @pid != Process.pid
          @pending.clear
          @pid = Process.pid
        end
        return unless @pending.add?(key)
      end

      @executor.post do
        # Accept a trailing update while the current broadcast is in flight.
        @mutex.synchronize { @pending.delete(key) }
        Rails.application.executor.wrap do
          Turbo::StreamsChannel.broadcast_action_to(stream, action: "operations_refresh",
            attributes: { topic: topic }, render: false)
        rescue Realtime::HttpBroadcaster::Error, Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout,
          SocketError, OpenSSL::SSL::SSLError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EPIPE, EOFError => error
          report(error)
        end
      end
    rescue Concurrent::RejectedExecutionError => error
      @mutex.synchronize { @pending.delete(key) }
      report(error)
    end

    def flush(timeout: 5)
      completed = Concurrent::Event.new
      @executor.post { completed.set }
      ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
        raise Timeout::Error, "Operations updates did not finish within #{timeout}s" unless completed.wait(timeout)
      end
    end

    def shutdown
      @executor.shutdown
      return if @executor.wait_for_termination(5)

      report(Timeout::Error.new("Operations updates did not finish before shutdown"))
      @executor.kill
    end

    def self.access_stream(user_id)
      "#{STREAM}:user:#{user_id}"
    end

    def self.access_changed(user_id)
      publish("access", stream: access_stream(user_id))
    end

    private

    def report(error)
      Rails.error.report(error, handled: true, severity: :error, source: "operations_updates")
    end

    DEFAULT = new

    class << self
      delegate :publish, :flush, :shutdown, to: "Realtime::OperationsUpdates::DEFAULT"
    end
  end
end
