require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
  end

  test "create" do
    post passwords_path, params: { email_address: @user.email_address }
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "reset instructions have been sent"
  end

  test "create for an unknown user redirects but sends no mail" do
    post passwords_path, params: { email_address: "missing-user@example.com" }
    assert_enqueued_emails 0
    assert_redirected_to new_session_path

    follow_redirect!
    assert_notice "reset instructions have been sent"
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "This link is invalid"
  end

  test "update" do
    assert_changes -> { @user.reload.password_digest } do
      put password_path(@user.password_reset_token), params: { password: "new-password-2026", password_confirmation: "new-password-2026" }
      assert_redirected_to new_session_path
    end

    follow_redirect!
    assert_notice "Password updated"
  end

  test "update with non matching passwords" do
    session = @user.sessions.create!
    token = @user.password_reset_token
    assert_no_changes -> { @user.reload.password_digest } do
      assert_no_enqueued_jobs do
        put password_path(token), params: { password: "no", password_confirmation: "match" }
        assert_response :unprocessable_entity
      end
    end

    assert Session.exists?(session.id)
    assert_select "[role=alert]"
  end

  test "сброс пароля отзывает сессии всех устройств и ставит отключение в очередь" do
    session_ids = 2.times.map { @user.sessions.create!.id }
    assert_enqueued_with(job: DisconnectSessionsJob, args: [ session_ids ]) do
      put password_path(@user.password_reset_token), params: { password: "new-password-2026", password_confirmation: "new-password-2026" }
    end
    assert_empty @user.sessions.reload
    assert_redirected_to new_session_path
  end

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
