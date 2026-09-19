require "test_helper"

class ConcurrencyConfigTest < ActiveSupport::TestCase
  test "нулевые, отрицательные и отсутствующие размеры отклоняются" do
    %i[rails_max_threads job_threads job_concurrency db_pool queue_db_pool].each do |key|
      [ 0, -1, nil ].each do |value|
        assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(key => value) }
      end
    end
  end

  test "невалидное целое не превращается в частично прочитанное число" do
    assert_raises(ArgumentError) { ConcurrencyConfig.new(job_threads: "3workers") }
    assert_raises(ArgumentError) { ConcurrencyConfig.new(job_threads: 3.5) }
  end

  test "пулы должны вмещать web и worker со служебными потоками" do
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(rails_max_threads: 6, db_pool: 5) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(job_threads: 6, db_pool: 5) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(queue_db_pool: 5) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(solid_queue_supervisor_mode: "fork", queue_db_pool: 4) }
  end

  test "async не должен молча игнорировать число процессов" do
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(job_concurrency: 2) }
    assert_raises(Anyway::Config::ValidationError) { ConcurrencyConfig.new(solid_queue_supervisor_mode: "unknown") }
    config = ConcurrencyConfig.new(solid_queue_supervisor_mode: "fork", job_concurrency: 2, queue_db_pool: 5)
    assert_equal 2, config.job_concurrency
  end

  test "Rails и Solid Queue читают согласованные размеры" do
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
