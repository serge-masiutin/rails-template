require "application_system_test_case"
require_relative "../test_helpers/agent_trace_test_helper"

class AgentPrismTest < ApplicationSystemTestCase
  include AgentTraceTestHelper

  setup do
    sign_in_through_form(users(:admin))
  end

  teardown do
    page.driver.headers = {}
    page.current_window.resize_to(1280, 900)
  end

  test "AgentPrism показывает трассу, инструмент, атрибуты и очищенный JSON" do
    capture_trace
    visit operations_agents_path
    assert_text "Трассы агентов"
    assert_text "TestAgent.summarize"
    assert_text "tool.lookup_record"
    click_button "Attributes"
    assert_text "starterapp.prompt_version"
    assert_text "request-123"
    click_button "RAW"
    assert_text "agent_invocation"
    assert_no_text "PRIVATE_"
    assert page.evaluate_script("getComputedStyle(document.body).backgroundColor") != "rgba(0, 0, 0, 0)"
    page.save_screenshot(Rails.root.join("tmp/screenshots/agent-prism-desktop.png"))
  end

  test "панель показывает отказ загрузки вместо пустого списка" do
    visit operations_agents_path
    assert_text "Трасс пока нет"
    users(:admin).update!(admin: false)
    click_button "Обновить"
    assert_selector '[role="alert"]', text: "HTTP 403"
  end

  test "на узком экране можно открыть ошибку инструмента" do
    capture_trace
    page.current_window.resize_to(390, 844)
    visit operations_agents_path
    find('[role="button"][aria-label*="span card for tool.lookup_record"]').click
    assert_text "ArgumentError"
    assert_button "Tree View"
    page.save_screenshot(Rails.root.join("tmp/screenshots/agent-prism-mobile.png"))
  end

  test "пустое состояние и явное обновление" do
    visit operations_agents_path
    assert_text "Трасс пока нет"
    capture_trace
    click_button "Обновить"
    assert_text "TestAgent.summarize"
    assert_no_text "Трасс пока нет"
  end
end
