require "test_helper"

class ObservabilityTest < ActionDispatch::IntegrationTest
  setup do
    @operations = Rails.application.config.x.operations
    Rails.application.config.x.operations = OperationsConfig.new(username: "operator", password: "a" * 32, metrics_token: "b" * 32)
    @authorization = ActionController::HttpAuthentication::Basic.encode_credentials("operator", "a" * 32)
  end

  teardown do
    Rails.application.config.x.operations = @operations
  end

  test "diagnostics and panel require operator access" do
    %w[/ops/health /ops/metrics].each do |path|
      get path
      assert_response :unauthorized
      get path, headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials("operator", "wrong") }
      assert_response :unauthorized
    end
  end

  test "panel shows Solid Queue after authentication" do
    sign_in_as(users(:admin))
    get "/ops/jobs"
    follow_redirect! while response.redirect?
    assert_response :success
    assert_select "a[href*=solid_queue]", text: "Workers"
    assert_equal "no-store", response.headers["Cache-Control"]
  end

  test "unconfigured access is denied" do
    Rails.application.config.x.operations = OperationsConfig.new(username: nil, password: nil, metrics_token: nil)
    get "/ops/metrics", headers: { "Authorization" => @authorization }
    assert_response :unauthorized
  end

  test "collector token cannot open the panel or health endpoint" do
    %w[/ops/health].each do |path|
      get path, headers: { "Authorization" => "Bearer #{"b" * 32}" }
      assert_response :unauthorized
    end
    get "/ops/metrics", headers: { "Authorization" => @authorization }
    assert_response :unauthorized
  end

  test "missing or stale worker makes health checks fail" do
    SolidQueue::Process.create!(kind: "Worker", name: "stale", last_heartbeat_at: 10.minutes.ago, pid: 1, hostname: "test")
    get "/ops/health", headers: { "Authorization" => @authorization }
    assert_response :service_unavailable
    assert_equal false, response.parsed_body.fetch("healthy")
    assert_equal 0, response.parsed_body.dig("queue", "processes", "worker")
  end

  test "diagnostics read heartbeat and queue state from PostgreSQL" do
    %w[Worker Dispatcher].each do |kind|
      SolidQueue::Process.create!(kind: kind, name: kind, last_heartbeat_at: Time.current, pid: 1, hostname: "test")
    end
    get "/ops/health", headers: { "Authorization" => @authorization }
    assert_response :success
    assert_equal true, response.parsed_body.fetch("healthy")
    assert_equal 1, response.parsed_body.dig("queue", "processes", "worker")
  end

  test "Yabeda exports HTTP and shared queue metrics" do
    get new_session_path
    get "/ops/metrics", headers: { "Authorization" => "Bearer #{"b" * 32}" }
    assert_response :success
    assert_match(/rails_requests_total\{[^\n]*controller="sessions"[^\n]*action="new"[^\n]*status="200"/, response.body)
    assert_includes response.body, 'starterapp_queue_processes{kind="worker"} 0'
    assert_includes response.body, 'starterapp_queue_jobs{state="failed"} 0'
    assert_includes response.body, "starterapp_queue_oldest_ready_age_seconds"
    refute_includes response.body, "email_address"
  end

  test "logs preserve correlation without exposing form values tokens or email arguments" do
    io = StringIO.new
    appender = SemanticLogger.add_appender(io: io, formatter: Observability::JsonFormatter.new)
    user = users(:one)
    token = user.password_reset_token
    post passwords_path, params: { email_address: user.email_address }, headers: { "X-Request-Id" => "correlation-test" }
    job = enqueued_jobs.last
    assert_equal "correlation-test", job.fetch("request_id")
    assert_equal MailDeliveryJob, job.fetch(:job)
    get edit_password_path(token)
    SemanticLogger.flush
    records = io.string.lines.map { |line| JSON.parse(line) }
    enqueue_log = records.find { |record| record["metric"] == "rails.job.enqueue" }
    assert_equal job.fetch("job_id"), enqueue_log.fetch("payload").fetch("job_id")
    request_log = records.find { |record| record.dig("metric") == "rails.controller.process_action" && record.dig("named_tags", "request_id") == "correlation-test" }
    assert_equal 303, request_log.fetch("payload").fetch("status")
    refute_includes io.string, user.email_address
    refute_includes io.string, token
  ensure
    SemanticLogger.remove_appender(appender) if appender
  end
end
