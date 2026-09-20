# The isolated test server enables CSRF and real AnyCable delivery.
require_relative "../../config/environment"
raise "Load testing requires RAILS_ENV=test" unless Rails.env.test?
ActionController::Base.allow_forgery_protection = true
ActionCable.server.config.allowed_request_origins = [ "http://host.docker.internal:3200" ]
run Rails.application
