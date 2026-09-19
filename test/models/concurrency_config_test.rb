require "test_helper"

class ConcurrencyConfigTest < ActiveSupport::TestCase
  test "zero negative and missing sizes are rejected" do
    %i[rails_max_threads job_threads job_concurrency db_pool queue_db_pool].each do |key|
      [ 0, -1, nil ].each do |value|
        assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(key => value) }
      end
    end
  end

  test "invalid integer input is not partially parsed" do
    assert_raises(ArgumentError) { ConcurrencyConfig.new(job_threads: "3workers") }
    assert_raises(ArgumentError) { ConcurrencyConfig.new(job_threads: 3.5) }
  end

  test "pools must fit web and worker plus internal threads" do
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(rails_max_threads: 6, db_pool: 5) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(job_threads: 6, db_pool: 5) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(queue_db_pool: 5) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(solid_queue_supervisor_mode: "fork", queue_db_pool: 4) }
  end

  test "async must not silently ignore the process count" do
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(job_concurrency: 2) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(solid_queue_supervisor_mode: "unknown") }
    config = ConcurrencyConfig.new(solid_queue_supervisor_mode: "fork", job_concurrency: 2, queue_db_pool: 5)
    assert_equal 2, config.job_concurrency
  end

  test "Rails and Solid Queue read consistent sizes" do
    settings = Rails.configuration.x.concurrency
    databases = Rails.application.config.database_configuration.fetch("test")
    workers = Rails.application.config_for(:queue).fetch(:workers)
    assert_equal settings.db_pool, databases.fetch("primary").fetch("max_connections")
    assert_equal settings.queue_db_pool, databases.fetch("queue").fetch("max_connections")
    assert_equal settings.job_threads, workers.first.fetch(:threads)
    assert_equal settings.job_concurrency, workers.first.fetch(:processes)
    assert_equal :thread, ActiveSupport::IsolatedExecutionState.isolation_level
  end
end
