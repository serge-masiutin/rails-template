require "application_system_test_case"

class BrowserDriverTest < ApplicationSystemTestCase
  test "Rails передаёт настройки запуска реальному браузеру" do
    visit new_session_path

    browser_options = page.driver.browser.options
    assert_equal 30, browser_options.process_timeout
    assert_equal 10, browser_options.timeout
    assert browser_options.js_errors
    assert_equal [ 1280, 900 ], browser_options.window_size
  end
end
