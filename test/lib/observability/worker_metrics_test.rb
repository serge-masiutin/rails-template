require "test_helper"

class Observability::WorkerMetricsTest < ActiveSupport::TestCase
  test "worker metrics require Bearer and expose no other routes" do
    previous = Rails.configuration.x.operations
    Rails.configuration.x.operations = OperationsConfig.new(metrics_token: "worker-metrics-test-credential-32")
    request = Rack::MockRequest.new(Observability::WorkerMetrics)

    assert_equal 401, request.get("/metrics").status
    assert_equal 401, request.get("/metrics", "HTTP_AUTHORIZATION" => "Bearer wrong").status
    response = request.get("/metrics", "HTTP_AUTHORIZATION" => "Bearer worker-metrics-test-credential-32")
    assert_equal 200, response.status
    assert_includes response.body, "starterapp_agent_generations"
    refute_includes response.body, "starterapp_queue_jobs"
    assert_equal "no-store", response.headers.fetch("cache-control")
    assert_equal 404, request.get("/up").status
    assert_equal 404, request.post("/metrics").status
  ensure
    Rails.configuration.x.operations = previous
  end
end
