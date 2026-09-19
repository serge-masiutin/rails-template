require "application_system_test_case"
require_relative "../test_helpers/agent_trace_test_helper"

Capybara.server_host = "0.0.0.0"
Capybara.server_port = 3100
Capybara.app_host = "http://127.0.0.1:3100"

class AnyCableScenario < ApplicationSystemTestCase
  include ActiveJob::TestHelper
  include AgentTraceTestHelper

  class ProbeJob < ApplicationJob
    def perform; end
  end

  self.use_transactional_tests = false

  setup do
    # Rails TestHelper replaces pubsub; restart restores the cable.yml adapter.
    ActionCable.server.restart
    assert_instance_of ActionCable::SubscriptionAdapter::AnyCable, ActionCable.server.pubsub
  end

  test "real Go server delivers Turbo Streams recovers missed messages and revokes sessions" do
    visit root_path
    fill_in "Email", with: users(:one).email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_selector "turbo-cable-stream-source[connected]", visible: :all

    publish_notice("First update")
    assert_text "First update"

    page.evaluate_async_script("const done = arguments[0]; import('cable').then(({ default: cable }) => { window.realtimeProbe = cable; done(true) })")
    page.execute_script("window.realtimeProbe.disconnect()")
    assert_no_selector "turbo-cable-stream-source[connected]", visible: :all
    publish_notice("Update while disconnected")
    page.execute_script("window.realtimeProbe.connect()")
    assert_text "Update while disconnected"

    # A correctly signed foreign stream must still reject the subscription.
    other_token = Turbo::StreamsChannel.signed_stream_name(users(:two).updates_stream_name)
    page.execute_script(<<~JS, other_token)
      const source = document.createElement('turbo-cable-stream-source')
      source.setAttribute('channel', 'UserUpdatesChannel')
      source.setAttribute('signed-stream-name', arguments[0])
      source.id = 'foreign-stream'
      document.body.appendChild(source)
      source.channel.on('close', () => source.setAttribute('rejected', ''))
    JS
    assert_selector "#foreign-stream[rejected]", visible: :all

    page.execute_script("document.body.dataset.beforeHistoryLoss = ''; window.realtimeProbe.disconnect()")
    assert_no_selector "turbo-cable-stream-source[connected]", visible: :all
    3.times { |index| publish_notice("History eviction #{index}") }
    page.execute_script("window.realtimeProbe.connect()")
    assert_no_selector "body[data-before-history-loss]"
    assert_selector "turbo-cable-stream-source[connected]", visible: :all

    perform_enqueued_jobs(only: DisconnectSessionsJob) { Session.revoke_all!(users(:one).sessions) }
    assert_no_selector "turbo-cable-stream-source[connected]", visible: :all
    visit account_path
    assert_text "Sign in to StarterApp"
  end


  test "admin receives queue and trace updates through Go without idle polling" do
    SolidQueue::Job.delete_all
    AgentTrace.delete_all
    sign_in_through_form(users(:admin))
    visit admin_root_path
    assert_selector "#operations-stream[connected]", visible: :all
    assert_selector '[data-state="live"]'
    assert_selector '[data-queue-state="ready"]', text: "0", exact_text: true
    SolidQueue::Job.enqueue(ProbeJob.new)
    assert_selector '[data-queue-state="ready"]', text: "1", exact_text: true
    SolidQueue::ReadyExecution.claim([ "default" ], 1, 1).first.perform
    assert_selector '[data-queue-state="ready"]', text: "0", exact_text: true

    # The fixed observation window checks absence of periodic HTTP rather than synchronizing DOM.
    requests = Capybara.using_wait_time(10) do
      page.evaluate_async_script(<<~JS)
      const done = arguments[0]
      setTimeout(() => {
        performance.clearResourceTimings()
        setTimeout(() => done(performance.getEntriesByType('resource').filter(entry => entry.initiatorType === 'fetch').length), 5500)
      }, 500)
    JS
    end
    assert_equal 0, requests

    within('nav[aria-label="Administration"]') { click_link "Mission Control" }
    assert_selector "#operations-stream[connected]", visible: :all
    click_link "Scheduled"
    assert_selector "#operations-stream[connected]", visible: :all
    SolidQueue::Job.enqueue(ProbeJob.new, scheduled_at: 1.hour.from_now)
    assert_text "AnyCableScenario::ProbeJob"

    within('nav[aria-label="Administration"]') { click_link "AgentPrism" }
    assert_selector "#operations-stream[connected]", visible: :all
    assert_text "No traces yet"
    capture_trace
    assert_text "TestAgent.summarize"
    click_button "RAW"
    capture_trace
    assert_text "Traces 2", normalize_ws: true
    assert_selector '[role="tab"][data-state="active"]', text: "RAW"
    users(:admin).update!(admin: false)
    assert_text "Access expired"
    assert_no_selector ".ops-viewer"
    assert_no_selector "#operations-stream", visible: :all
  ensure
    users(:admin).update!(admin: true)
    SolidQueue::Job.delete_all
    AgentTrace.delete_all
  end

  private

  def publish_notice(message)
    Turbo::StreamsChannel.broadcast_update_to(users(:one).updates_stream_name,
      target: "flash", html: ApplicationController.render(Ui::NoticeComponent.new(message: message, variant: :notice), layout: false))
  end
end
