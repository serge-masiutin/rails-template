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
    assert_text "Application status"
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-desktop.png"))
    within('nav[aria-label="Administration"]') { click_link "Mission Control" }
    assert_link "Workers"
    assert_selector 'section[lang="en"]'
    assert_title(/Mission Control/)
    within('nav[aria-label="Administration"]') { click_link "AgentPrism" }
    assert_text "No traces yet"
    within('nav[aria-label="Administration"]') { click_link "Metrics and logs" }
    assert_text "Investigate an error"
    within('nav[aria-label="Administration"]') { click_link "Overview" }
    assert_text "Application status"
  end

  test "Native получает доступ из профиля, узкий экран не прокручивается вбок" do
    page.current_window.resize_to(390, 844)
    page.driver.add_headers("User-Agent" => "Hotwire Native Android")
    sign_in_through_form(users(:admin))
    click_link "Open profile"
    click_link "Open admin"
    assert_text "Application status"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-mobile.png"))
    within('nav[aria-label="Administration"]') { click_link "Metrics and logs" }
    assert_text "Investigate an error"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  end
end
