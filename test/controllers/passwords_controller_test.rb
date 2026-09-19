require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "reset request form submits the email to the correct route" do
    get new_password_path
    assert_response :success
    assert_select 'form[action=?][method="post"]', passwords_path do
      assert_select 'input[name="email_address"][type="email"]'
      assert_select 'input[type="submit"]'
    end
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

  test "password form preserves the token and both password fields" do
    token = @user.password_reset_token
    get edit_password_path(token)
    assert_response :success
    assert_select 'form[action=?][method="post"]', password_path(token) do
      assert_select 'input[name="_method"][value="put"]'
      %w[password password_confirmation].each { |name| assert_select 'input[name=?][type="password"]', name }
      assert_select 'input[type="submit"]'
    end
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_notice "This link is invalid"
  end

  test "reset changes the password, revokes only the owner sessions and returns 303" do
    session_ids = 2.times.map { @user.sessions.create!.id }
    other_session = users(:two).sessions.create!
    assert_changes -> { @user.reload.password_digest } do
      assert_enqueued_with(job: DisconnectSessionsJob, args: [ session_ids ]) do
        put password_path(@user.password_reset_token), params: { password: "new-password-2026", password_confirmation: "new-password-2026" }
      end
    end
    assert_empty @user.sessions.reload
    assert Session.exists?(other_session.id)
    assert_response :see_other
    assert_redirected_to new_session_path

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

  private
    def assert_notice(text)
      assert_select "div", /#{text}/
    end
end
