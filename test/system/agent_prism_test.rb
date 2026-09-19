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

  test "AgentPrism shows trace tool call attributes and sanitized JSON" do
    capture_trace
    visit operations_agents_path
    assert_selector "h1", text: "AgentPrism"
    assert_selector '.ops-viewer[lang="en"]'
    assert_title(/AgentPrism/)
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

  test "panel shows load failure rather than an empty list" do
    visit operations_agents_path
    assert_text "No traces yet"
    users(:admin).update!(admin: false)
    announce_update("access")
    assert_selector '[role="alert"]', text: "Access expired", wait: 12
    assert_no_selector ".ops-viewer"
  end

  test "tool call errors can be opened on a narrow screen" do
    capture_trace
    page.current_window.resize_to(390, 844)
    visit operations_agents_path
    find('[role="button"][aria-label*="span card for tool.lookup_record"]').click
    assert_text "ArgumentError"
    assert_button "Tree View"
    page.save_screenshot(Rails.root.join("tmp/screenshots/agent-prism-mobile.png"))
  end

  private

  # This suite checks rendering; bin/realtime-test verifies actual transport.
  def announce_update(topic)
    page.execute_script("Turbo.renderStreamMessage(arguments[0])", %(<turbo-stream action="operations_refresh" topic="#{topic}"></turbo-stream>))
  end
end
