class DispatchSessionDisconnectsJob < ApplicationJob
  def perform
    SessionDisconnect.dispatch_pending
  end
end
