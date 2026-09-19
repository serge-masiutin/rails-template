require "test_helper"

class AuthenticationContractTest < ActionDispatch::IntegrationTest
  test "required fields are checked at the HTTP boundary" do
    post session_path, params: { email_address: users(:one).email_address }
    assert_response :bad_request
  end

  test "successful sign-in uses 303 and returns to the original path" do
    get account_path
    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_response :see_other
    assert_redirected_to account_path
  end

  test "HEAD preserves the destination for return after sign-in" do
    head account_path
    assert_response :see_other
    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_redirected_to account_path
  end

  test "password reset revokes existing sessions" do
    user = users(:one)
    user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    put password_path(user.password_reset_token), params: { password: "a-new-password-2026", password_confirmation: "a-new-password-2026" }
    assert_response :see_other
    assert_empty user.sessions.reload
  end

  test "sign-in and reset rate limits use 303" do
    [ session_path, passwords_path ].each do |path|
      11.times do
        post path, params: { email_address: users(:one).email_address, password: "password" }
      end
      assert_response :see_other
      assert_equal "Try again later.", flash[:alert]
    end
  end

  test "invalid password-reset token redirects with 303" do
    put password_path("invalid-token"), params: { password: "new-password-2026", password_confirmation: "new-password-2026" }
    assert_response :see_other
    assert_redirected_to new_password_path
  end

  test "sign-out with an expired session redirects to sign-in with 303" do
    delete session_path
    assert_response :see_other
    assert_redirected_to new_session_path

    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_redirected_to root_path
  end
end
