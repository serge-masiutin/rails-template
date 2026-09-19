require "test_helper"
require "capybara/cuprite"

# Create the queue pool before fixtures so transactions open and close
# in the test thread, not first during a Mission Control request from Puma.
SolidQueue::Record.connection_pool

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Rails re-registers Cuprite when creating the test, so configure options here.
  # Cold Chrome startup has a separate budget; browser commands wait up to 10 seconds.
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
