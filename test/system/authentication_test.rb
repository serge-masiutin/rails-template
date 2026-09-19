require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  test "sign-in Turbo navigation to account and sign-out" do
    visit root_path
    assert_text "Sign in to StarterApp"
    fill_in "Email", with: users(:one).email_address
    fill_in "Password", with: "password"
    click_button "Sign in"
    assert_text "Workspace"
    page.execute_script("window.starterAppNavigationProbe = true")
    click_link "Open profile"
    assert_text users(:one).email_address
    assert page.evaluate_script("window.starterAppNavigationProbe === true")
    click_button "Sign out"
    assert_text "Sign in to StarterApp"
  end

  test "Stimulus expands help" do
    visit new_session_path
    assert_no_link "Reset password"
    click_button "Need help signing in?"
    assert_link "Reset password"
    assert_selector "button[aria-expanded=true]"
  end
end
