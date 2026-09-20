require "test_helper"
require "capybara/cuprite"

# Create the queue pool before fixtures so the test thread owns its transaction,
# before Mission Control first uses it from Puma.
SolidQueue::Record.connection_pool

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Rails registers Cuprite for each test, so configure its options here.
  # Allow extra time for cold Chrome startup in CI; browser commands have a 10-second timeout.
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
