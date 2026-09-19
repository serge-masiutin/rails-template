ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
Minitest.load :test_prof
require "webmock/minitest"
require "n_plus_one_control/minitest"
WebMock.disable_net_connect!(allow_localhost: true)
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # На macOS Ruby 4/libpq падает после fork; Linux CI использует процессы.
    parallelize(workers: Integer(ENV.fetch("PARALLEL_WORKERS", RUBY_PLATFORM.include?("darwin") ? 1 : 2)))

    fixtures :all
    setup { Rails.cache.clear }
  end
end
