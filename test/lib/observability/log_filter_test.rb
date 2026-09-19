require "test_helper"

class Observability::LogFilterTest < ActionDispatch::IntegrationTest
  setup do
    @log = StringIO.new
    @appender = SemanticLogger.add_appender(io: @log, formatter: Observability::JsonFormatter.new, filter: Observability::LogFilter)
    @operations = Rails.configuration.x.operations
    Rails.configuration.x.operations = OperationsConfig.new(username: "operator", password: "probe-password-000000000000000000000", metrics_token: "probe-token-000000000000000000000000")
  end

  teardown do
    Rails.configuration.x.operations = @operations
    SemanticLogger.remove_appender(@appender)
  end

  test "successful scrape and liveness summaries are quiet while 401 and 503 remain" do
    get operations_metrics_path, headers: { "Authorization" => "Bearer probe-token-000000000000000000000000" }
    assert_response :ok
    get rails_health_check_path
    assert_response :ok
    assert_empty completed_requests

    get operations_metrics_path
    assert_response :unauthorized
    get operations_health_path, headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("operator", "probe-password-000000000000000000000") }
    assert_response :service_unavailable
    assert_equal [ 401, 503 ], completed_requests.map { |entry| entry.fetch("payload").fetch("status") }
  end

  test "ordinary requests and separate probe failures remain in logs" do
    get new_session_path
    assert_response :ok
    assert_equal 1, completed_requests.size
    logger = SemanticLogger["Operations::MetricsController"]
    logger.error(message: "Probe failed", exception: RuntimeError.new("secret"))
    SemanticLogger.flush
    assert_includes @log.string, "RuntimeError"
  end

  private

  def completed_requests
    SemanticLogger.flush
    @log.string.lines.map { |line| JSON.parse(line) }.select { |entry| entry["metric"] == "rails.controller.process_action" }
  end
end
