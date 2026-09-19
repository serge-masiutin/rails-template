# CSRF и настоящая доставка AnyCable проверяются только на изолированном test-сервере.
require_relative "../../config/environment"
raise "Нагрузочный стенд требует RAILS_ENV=test" unless Rails.env.test?
ActionController::Base.allow_forgery_protection = true
ActionCable.server.config.allowed_request_origins = [ "http://host.docker.internal:3200" ]
run Rails.application
