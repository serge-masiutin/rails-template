require "application_system_test_case"

class AdminNavigationTest < ApplicationSystemTestCase
  teardown do
    page.current_window.resize_to(1280, 900)
    page.driver.headers = {}
  end

  test "вход возвращает в админку, навигация связывает все служебные экраны" do
    visit admin_root_path
    fill_in "Email", with: users(:admin).email_address
    fill_in "Пароль", with: "password"
    click_button "Войти"
    assert_text "Состояние приложения"
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-desktop.png"))
    within('nav[aria-label="Администрирование"]') { click_link "Mission Control" }
    assert_link "Workers"
    assert_selector 'section[lang="en"]'
    assert_title(/Mission Control/)
    within('nav[aria-label="Администрирование"]') { click_link "AgentPrism" }
    assert_text "Пока нет данных"
    within('nav[aria-label="Администрирование"]') { click_link "Метрики и логи" }
    assert_text "Как найти ошибку"
    within('nav[aria-label="Администрирование"]') { click_link "Обзор" }
    assert_text "Состояние приложения"
  end

  test "Native получает доступ из профиля, узкий экран не прокручивается вбок" do
    page.current_window.resize_to(390, 844)
    page.driver.add_headers("User-Agent" => "Hotwire Native Android")
    sign_in_through_form(users(:admin))
    click_link "Открыть профиль"
    click_link "Открыть админку"
    assert_text "Состояние приложения"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
    page.save_screenshot(Rails.root.join("tmp/screenshots/admin-mobile.png"))
    within('nav[aria-label="Администрирование"]') { click_link "Метрики и логи" }
    assert_text "Как найти ошибку"
    assert page.evaluate_script("document.documentElement.scrollWidth <= window.innerWidth")
  end
end
