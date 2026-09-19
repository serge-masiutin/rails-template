module Admin
  class ObservabilityController < BaseController
    def show
      @operations = Rails.configuration.x.operations
    end
  end
end
