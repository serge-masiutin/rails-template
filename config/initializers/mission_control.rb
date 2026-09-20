Rails.application.config.after_initialize do
  # Reuse the dashboard's Stimulus application to preserve its Turbo forms.
  MissionControl::Jobs.importmap.pin "admin_jobs", to: "admin_jobs.js"
  MissionControl::Jobs.importmap.pin "live_updates", to: "live_updates.js"
  MissionControl::Jobs.importmap.pin "admin/live_region_controller", to: "controllers/live_region_controller.js"

  # @anycable/turbo-stream owns the stream source; prevent duplicate registration by turbo-rails.
  MissionControl::Jobs.importmap.pin "@hotwired/turbo-rails", to: "@hotwired--turbo.js"
  MissionControl::Jobs.importmap.pin "@hotwired/turbo", to: "@hotwired--turbo.js"
  MissionControl::Jobs.importmap.pin "operations_stream", to: "operations_stream.js"
  MissionControl::Jobs.importmap.pin "cable", to: "cable.js"
  MissionControl::Jobs.importmap.pin "@anycable/turbo-stream", to: "@anycable--turbo-stream.js"
  MissionControl::Jobs.importmap.pin "@anycable/web", to: "@anycable--web.js"
  MissionControl::Jobs.importmap.pin "@anycable/core", to: "@anycable--core.js"
  MissionControl::Jobs.importmap.pin "nanoevents", to: "nanoevents.js"
end
