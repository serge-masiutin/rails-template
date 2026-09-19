# CSRF and real AnyCable delivery run only on the isolated test server.
require_relative "../../config/environment"
raise "Load harness requires RAILS_ENV=test" unless Rails.env.test?
ActionController::Base.allow_forgery_protection = true
ActionCable.server.config.allowed_request_origins = [ "http://host.docker.internal:3200" ]
run Rails.application
