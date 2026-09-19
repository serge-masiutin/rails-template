module Operations
  class HealthController < BaseController
    def show
      snapshot = HealthSnapshot.capture
      render json: snapshot, status: snapshot.fetch(:healthy) ? :ok : :service_unavailable
    end
  end
end
