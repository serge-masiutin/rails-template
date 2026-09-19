class DisconnectSessionsJob < ApplicationJob
  # Отзыв cookie не зависит от доступности AnyCable; временный сетевой сбой повторяем ограниченно.
  retry_on Net::OpenTimeout, Net::ReadTimeout, Net::WriteTimeout, Errno::ECONNREFUSED,
    wait: 5.seconds, attempts: 3

  def perform(session_ids)
    session_ids.each do |session_id|
      ActionCable.server.remote_connections.where(session_id: session_id).disconnect(reconnect: false)
    end
  end
end
