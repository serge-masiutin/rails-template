require "test_helper"
require_relative "previews/passwords_mailer_preview"

class PasswordsMailerPreviewTest < ActiveSupport::TestCase
  test "preview works without real users and does not persist an account" do
    Session.delete_all
    User.delete_all
    assert_no_difference "User.count" do
      message = PasswordsMailerPreview.new.reset.message
      assert_equal [ "preview@example.test" ], message.to
      assert_includes message.html_part.body.decoded, "Reset password"
    end
  end
end
