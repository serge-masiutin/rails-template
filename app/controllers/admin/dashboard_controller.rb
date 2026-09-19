module Admin
  class DashboardController < BaseController
    def show
      @health = Operations::HealthSnapshot.capture
    end
  end
end
