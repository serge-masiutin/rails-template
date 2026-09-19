require "application_system_test_case"

class AdminNavigationTest < ApplicationSystemTestCase
  teardown do
    page.current_window.resize_to(1280, 900)
    page.driver.headers = {}
  end

  test "вход возвращает в админку, навигация связывает все служебные экраны" do
    visit admin_root_path
    fill_in "Email", with: users(:admin).email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_selector "h1", text: "Overview"
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-desktop.png"))
    within('nav[aria-label="Administration"]') { click_link "Mission Control" }
    assert_link "Workers"
    assert_selector '[data-live-region-target="status"][data-state="live"]', text: "Live"
    click_link "Workers"
    assert_selector "#jobs-content"
    assert_no_selector '[data-state="offline"]'
    assert_selector 'section[lang="en"]'
    assert_title(/Mission Control/)
    within('nav[aria-label="Administration"]') { click_link "AgentPrism" }
    assert_text "No traces yet"
    within('nav[aria-label="Administration"]') { click_link "Monitoring" }
    assert_selector "h1", text: "Monitoring"
    within('nav[aria-label="Administration"]') { click_link "Overview" }
    assert_selector "h1", text: "Overview"
  end

  test "Native получает доступ из профиля, узкий экран не прокручивается вбок" do
    page.current_window.resize_to(390, 844)
    page.driver.add_headers("User-Agent" => "Hotwire Native Android")
    sign_in_through_form(users(:admin))
    click_link "Open profile"
    click_link "Open admin"
    assert_selector "h1", text: "Overview"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-mobile.png"))
    within('nav[aria-label="Administration"]') { click_link "Monitoring" }
    assert_selector "h1", text: "Monitoring"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  end
  test "обзор обновляет очередь без действий пользователя и закрывается после отзыва роли" do
    sign_in_through_form(users(:admin))
    visit admin_root_path
    assert_selector '[data-queue-state="ready"]', text: "0", exact_text: true
    SolidQueue::Job.enqueue(ApplicationJob.new)
    assert_selector '[data-queue-state="ready"]', text: "1", exact_text: true, wait: 12
    assert_no_button "Refresh"
    users(:admin).update!(admin: false)
    assert_text "Access expired. Sign in again.", wait: 12
    assert_no_selector "[data-queue-state]"
  end

  test "Mission Control сохраняет введённый фильтр при автообновлении" do
    sign_in_through_form(users(:admin))
    SolidQueue::Job.enqueue(ApplicationJob.new, scheduled_at: 1.hour.from_now)
    visit mission_control_jobs_path
    click_link "Scheduled"
    fill_in "Job class name", with: "Probe"
    assert_text "Paused while editing", wait: 12
    assert_field "Job class name", with: "Probe"
    find("h1", text: "Mission Control").click
    assert_text "Live · 5s", wait: 12
    assert_no_text "Reconnecting"
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-jobs.png"))
  end
end
