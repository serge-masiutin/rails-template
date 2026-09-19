require "test_helper"
require_relative "../../test_helpers/agent_trace_test_helper"

class Operations::AgentsControllerTest < ActionDispatch::IntegrationTest
  include AgentTraceTestHelper

  setup { @authorization = operator_credentials }
  teardown { Rails.configuration.x.operations = @previous_operations }

  test "HTML и JSON требуют служебную авторизацию" do
    [ operations_agents_path, operations_agents_path(format: :json) ].each do |path|
      get path
      assert_response :unauthorized
      get path, headers: { "Authorization" => "Basic wrong" }
      assert_response :unauthorized
    end
  end

  test "нет настроек доступа — нет открытого просмотрщика" do
    Rails.configuration.x.operations = OperationsConfig.new(username: nil, password: nil)
    get operations_agents_path, headers: { "Authorization" => @authorization }
    assert_response :unauthorized
  end

  test "авторизованная страница подключает только отдельную сборку" do
    get operations_agents_path, headers: { "Authorization" => @authorization }
    assert_response :success
    assert_equal "no-store", response.headers.fetch("Cache-Control")
    assert_select "main#agent-prism[data-url]"
    assert_select 'script[src*="agent-prism"]', 1
    assert_select 'script[type="importmap"]', 0
  end

  test "JSON пагинируется и не выдаёт старые трассы или исходные тексты" do
    expired = capture_trace
    expired.update!(started_at: 8.days.ago)
    21.times { capture_trace }
    get operations_agents_path(format: :json), headers: { "Authorization" => @authorization }
    assert_response :success
    assert_equal "no-store", response.headers.fetch("Cache-Control")
    first_page = response.parsed_body
    assert_equal 1, first_page.fetch("version")
    assert_equal 20, first_page.fetch("data").size
    refute_includes response.body, "PRIVATE_"
    get operations_agents_path(format: :json, before: first_page.fetch("next_cursor")), headers: { "Authorization" => @authorization }
    assert_equal 1, response.parsed_body.fetch("data").size
    assert_nil response.parsed_body.fetch("next_cursor")
  end

  test "некорректный курсор отклоняется" do
    get operations_agents_path(format: :json, before: "bad"), headers: { "Authorization" => @authorization }
    assert_response :bad_request
  end
end
