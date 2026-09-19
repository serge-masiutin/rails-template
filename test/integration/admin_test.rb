require "test_helper"

class AdminTest < ActionDispatch::IntegrationTest
  PAGES = %w[/admin /admin/observability /ops/jobs /ops/agents].freeze

  test "гость входит через обычную форму, JSON возвращает 401" do
    PAGES.each do |path|
      get path
      assert_redirected_to "/session/new"
      assert_equal "no-store", response.headers.fetch("Cache-Control")
    end
    get operations_agents_path(format: :json)
    assert_response :unauthorized
  end

  test "обычный пользователь не получает HTML и JSON даже с Native User-Agent" do
    sign_in_as(users(:one))
    [ *PAGES, operations_agents_path(format: :json) ].each do |path|
      get path, headers: { "User-Agent" => "Hotwire Native Android" }
      assert_response :forbidden
      assert_equal "no-store", response.headers.fetch("Cache-Control")
    end
    get account_path
    assert_select 'a[href="/admin"]', 0
  end

  test "Basic и Bearer не заменяют сессию администратора" do
    previous = Rails.configuration.x.operations
    Rails.configuration.x.operations = OperationsConfig.new(username: "operator", password: "a" * 32, metrics_token: "b" * 32)
    credentials = [ ActionController::HttpAuthentication::Basic.encode_credentials("operator", "a" * 32), "Bearer #{"b" * 32}" ]
    credentials.each do |authorization|
      PAGES.each do |path|
        get path, headers: { "Authorization" => authorization }
        assert_redirected_to "/session/new"
      end
      get operations_agents_path(format: :json), headers: { "Authorization" => authorization }
      assert_response :unauthorized
    end
  ensure
    Rails.configuration.x.operations = previous
  end

  test "администратор видит общую навигацию, право отзывается на следующем запросе" do
    sign_in_as(users(:admin))
    PAGES.each do |path|
      get path
      follow_redirect! while response.redirect?
      assert_response :success
      assert_select 'nav[aria-label="Administration"] a', 5
      assert_select 'nav[aria-label="Administration"] a', text: "AgentPrism"
      assert_select 'nav[aria-label="Administration"] a', text: "Mission Control"
      assert_equal "no-store", response.headers.fetch("Cache-Control")
      assert_select 'meta[name="turbo-cache-control"][content="no-cache"]'
    end
    users(:admin).update!(admin: false)
    [ *PAGES, operations_agents_path(format: :json) ].each do |path|
      get path
      assert_response :forbidden
    end
  end

  test "панель показывает настоящий heartbeat и сообщает об остановленной очереди" do
    sign_in_as(users(:admin))
    get admin_root_path
    assert_select '[role="alert"]', text: /some required queue processes/
    %w[Worker Dispatcher Scheduler Ready Scheduled Claimed Blocked Failed].each do |label|
      assert_select "dt", text: label
    end
    %w[Worker Dispatcher].each do |kind|
      SolidQueue::Process.create!(kind: kind, name: kind, last_heartbeat_at: Time.current, pid: 1, hostname: "test")
    end
    get admin_root_path
    assert_select '[role="status"]', text: /All required queue processes are sending heartbeats/
  end

  test "сбой БД очереди показан явно и не выдаёт успешные счётчики" do
    sign_in_as(users(:admin))
    SolidQueue::Record.transaction(requires_new: true) do
      SolidQueue::Record.connection.execute("ALTER TABLE solid_queue_processes RENAME TO unavailable_processes")
      get admin_root_path
      assert_response :success
      assert_select '[role="alert"]', text: /Could not read the database/
      assert_select "#queue-title", 0
      refute_includes response.body, "PG::UndefinedTable"
      raise ActiveRecord::Rollback
    end
  end

  test "ссылки мониторинга опциональны, credentials в HTML не попадают" do
    previous = Rails.configuration.x.operations
    Rails.configuration.x.operations = OperationsConfig.new(username: "operator", password: "a" * 32, metrics_token: "b" * 32,
      grafana_url: "https://metrics.example.com/dashboard", prometheus_url: nil, logs_url: nil)
    sign_in_as(users(:admin))
    get admin_observability_path
    assert_response :success
    assert_select 'a[href="https://metrics.example.com/dashboard"][rel="noopener noreferrer"]'
    assert_select "p", text: "URL not configured", count: 2
    refute_includes response.body, "a" * 32
    refute_includes response.body, "b" * 32
    assert_equal "same-origin", response.headers.fetch("Referrer-Policy")
  ensure
    Rails.configuration.x.operations = previous
  end

  test "сессия администратора не заменяет технические credentials" do
    sign_in_as(users(:admin))
    %w[/ops/health /ops/metrics].each do |path|
      get path
      assert_response :unauthorized
    end
  end

  test "мутации Mission Control требуют роли и CSRF" do
    path = "/ops/jobs/applications/invalid/queues/default/pause"
    sign_in_as(users(:one))
    post path
    assert_response :forbidden

    sign_in_as(users(:admin))
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    post path
    assert_response :unprocessable_entity
  ensure
    ActionController::Base.allow_forgery_protection = previous unless previous.nil?
  end
end
