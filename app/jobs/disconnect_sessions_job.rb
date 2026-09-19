class DisconnectSessionsJob < ApplicationJob
  # Cookie revocation is independent of AnyCable availability; transient network retries are bounded.
  retry_on Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout, Errno::ECONNREFUSED,
    wait: 5.seconds, attempts: 3

  def perform(session_ids)
    session_ids.each do |session_id|
      ActionCable.server.remote_connections.where(session_id: session_id).disconnect(reconnect: false)
    end
  end
end
