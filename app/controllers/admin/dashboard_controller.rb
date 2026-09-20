module Admin
  class DashboardController < BaseController
    def show
      @health = Observability::Health.capture
    end
  end
end
