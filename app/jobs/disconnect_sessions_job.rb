class DisconnectSessionsJob < ApplicationJob
  # Cookie revocation must succeed while AnyCable is unavailable; retry disconnects separately.
  retry_on Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout, Errno::ECONNREFUSED,
    wait: 5.seconds, attempts: 3

  def perform(session_ids, outbox_id: nil)
    # Existing queued jobs without an outbox ID retain their original contract.
    if outbox_id
      intent = SessionDisconnect.find_by(id: outbox_id)
      return unless intent
      session_ids = intent.session_ids
    end

    session_ids.each do |session_id|
      ActionCable.server.remote_connections.where(session_id: session_id).disconnect(reconnect: false)
    end
    # A crash before this acknowledgement may repeat disconnects, which are idempotent.
    intent&.destroy!
  end
end
