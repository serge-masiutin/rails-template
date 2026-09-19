require "application_system_test_case"

class AdminNavigationTest < ApplicationSystemTestCase
  teardown do
    page.current_window.resize_to(1280, 900)
    page.driver.headers = {}
  end

  test "sign-in returns to admin and shared navigation links every operations screen" do
    visit admin_root_path
    fill_in "Email", with: users(:admin).email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_selector "h1", text: "Overview"
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-desktop.png"))
    within('nav[aria-label="Administration"]') { click_link "Mission Control" }
    assert_link "Workers"
    assert_selector '[data-live-region-target="status"]'
    click_link "Workers"
    assert_selector "#jobs-content"
    assert_selector 'section[lang="en"]'
    assert_title(/Mission Control/)
    within('nav[aria-label="Administration"]') { click_link "AgentPrism" }
    assert_text "No traces yet"
    within('nav[aria-label="Administration"]') { click_link "Monitoring" }
    assert_selector "h1", text: "Monitoring"
    within('nav[aria-label="Administration"]') { click_link "Overview" }
    assert_selector "h1", text: "Overview"
  end

  test "Native opens admin from account and narrow screens have no horizontal overflow" do
    previous_environment = Rails.env
    Rails.env = "development"
    page.current_window.resize_to(390, 844)
    page.driver.add_headers("User-Agent" => "Hotwire Native Android")
    sign_in_through_form(users(:admin))
    click_link "Open profile"
    click_link "Open admin"
    assert_selector "h1", text: "Overview"
    assert_link "Lookbook ↗", href: "/lookbook"
    assert_link "Mail previews ↗", href: "/rails/mailers"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-mobile.png"))
    within('nav[aria-label="Administration"]') { click_link "Monitoring" }
    assert_selector "h1", text: "Monitoring"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  ensure
    Rails.env = previous_environment
  end
  test "overview updates the queue automatically and closes after role revocation" do
    sign_in_through_form(users(:admin))
    visit admin_root_path
    assert_selector '[data-queue-state="ready"]', text: "0", exact_text: true
    SolidQueue::Job.enqueue(ApplicationJob.new)
    announce_update("queue")
    assert_selector '[data-queue-state="ready"]', text: "1", exact_text: true, wait: 12
    assert_no_button "Refresh"
    users(:admin).update!(admin: false)
    announce_update("access")
    assert_text "Access expired. Sign in again.", wait: 12
    assert_no_selector "[data-queue-state]"
  end

  test "Mission Control preserves filter input during live updates" do
    sign_in_through_form(users(:admin))
    SolidQueue::Job.enqueue(ApplicationJob.new, scheduled_at: 1.hour.from_now)
    visit mission_control_jobs_path
    click_link "Scheduled"
    fill_in "Job class name", with: "Probe"
    assert_text "0 jobs found"
    find_field("Job class name").click
    announce_update("queue")
    assert_text "Paused while editing", wait: 12
    assert_field "Job class name", with: "Probe"
    find("h1", text: "Mission Control").click
    assert_no_text "Paused while editing", wait: 12
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-jobs.png"))
  end
  private

  # This suite checks rendering; bin/realtime-test verifies actual transport.
  def announce_update(topic)
    page.execute_script("Turbo.renderStreamMessage(arguments[0])", %(<turbo-stream action="operations_refresh" topic="#{topic}"></turbo-stream>))
  end
end
