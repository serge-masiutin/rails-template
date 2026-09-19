module Operations
  # The channel sends only a signal; fresh HTML/JSON requests recheck the role.
  module Updates
    STREAM = "operations:updates"

    def self.publish(topic, stream: STREAM)
      Turbo::StreamsChannel.broadcast_action_to(stream, action: "operations_refresh",
        attributes: { topic: topic }, render: false)
    rescue Realtime::HttpBroadcaster::Error, Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout,
      SocketError, OpenSSL::SSL::SSLError, Errno::ECONNREFUSED, Errno::ECONNRESET, Errno::EPIPE, EOFError => error
      # Unavailable diagnostics must not undo a committed job.
      Rails.error.report(error, handled: true, severity: :error, source: "operations_updates")
    end

    def self.access_stream(user_id)
      "#{STREAM}:user:#{user_id}"
    end

    def self.access_changed(user_id)
      publish("access", stream: access_stream(user_id))
    end
  end
end
