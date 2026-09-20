module Operations
  class HealthController < BaseController
    def show
      snapshot = Observability::Health.capture
      render json: snapshot, status: snapshot.fetch(:healthy) ? :ok : :service_unavailable
    end
  end
end
