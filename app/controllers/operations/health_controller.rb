module Operations
  class HealthController < BaseController
    def show
      ApplicationRecord.connection_pool.with_connection { |connection| connection.select_value("SELECT 1") }
      snapshot = QueueSnapshot.capture
      required = Rails.env.production? ? %i[worker dispatcher scheduler] : %i[worker dispatcher]
      healthy = required.all? { |kind| snapshot.fetch(:processes).fetch(kind.to_s).positive? }
      render json: { healthy: healthy, queue: snapshot }, status: healthy ? :ok : :service_unavailable
    rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid => error
      Rails.logger.error(message: "Не удалось проверить базу данных", exception: error)
      render json: { healthy: false, error: "database_unavailable" }, status: :service_unavailable
    end
  end
end
