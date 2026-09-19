require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "вход, Turbo-переход в профиль и выход" do
    visit root_path
    assert_text "Войти в StarterApp"
    fill_in "Email", with: users(:one).email_address
    fill_in "Пароль", with: "password"
    click_button "Войти"
    assert_text "Рабочее пространство"
    page.execute_script("window.starterAppNavigationProbe = true")
    click_link "Открыть профиль"
    assert_text users(:one).email_address
    assert page.evaluate_script("window.starterAppNavigationProbe === true")
    click_button "Выйти"
    assert_text "Войти в StarterApp"
  end

  test "Stimulus раскрывает помощь" do
    visit new_session_path
    assert_no_link "Восстановить пароль"
    click_button "Нужна помощь со входом?"
    assert_link "Восстановить пароль"
    assert_selector "button[aria-expanded=true]"
  end
end
