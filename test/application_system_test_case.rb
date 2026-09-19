require "test_helper"
require "capybara/cuprite"

# Пул очереди создаётся до fixtures: транзакция должна открыться и закрыться
# в потоке теста, а не впервые открыться при запросе Mission Control из Puma.
SolidQueue::Record.connection_pool

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Rails регистрирует Cuprite заново при создании теста, поэтому параметры задаются здесь.
  # Холодный запуск Chrome в CI получает отдельный бюджет; команды браузера ждут до 10 секунд.
  driven_by :cuprite, screen_size: [ 1280, 900 ], options: {
    js_errors: true, timeout: 10, process_timeout: 30
  }

  def sign_in_through_form(user)
    visit new_session_path
    fill_in "Email", with: user.email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_text "Workspace"
  end
end
