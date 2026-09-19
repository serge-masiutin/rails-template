require "test_helper"

class PasswordResetAtomicityTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  test "сбой БД при отзыве сессий откатывает смену пароля" do
    user = User.create!(email_address: "reset-atomicity@example.test", password: "old-password-2026")
    session = user.sessions.create!
    token = user.password_reset_token
    connection = ApplicationRecord.connection
    # Реальный отказ DELETE проверяет rollback без подмены методов Session.
    connection.create_table :password_reset_session_guards do |table|
      table.references :session, foreign_key: true
    end
    connection.execute("INSERT INTO password_reset_session_guards (session_id) VALUES (#{Integer(session.id)})")

    assert_no_changes -> { user.reload.password_digest } do
      assert_no_enqueued_jobs do
        assert_raises(ActiveRecord::InvalidForeignKey) do
          put password_path(token), params: { password: "new-password-2026", password_confirmation: "new-password-2026" }
        end
      end
    end
    assert Session.exists?(session.id)
  ensure
    connection&.drop_table(:password_reset_session_guards, if_exists: true)
    user&.destroy!
  end
end
