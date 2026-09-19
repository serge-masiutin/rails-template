require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "new users have no administrator access" do
    assert_equal false, User.new.admin?
  end

  test "normalizes email and rejects duplicates" do
    user = User.new(email_address: " ONE@EXAMPLE.COM ", password: "valid-password-2026")
    assert_not user.valid?
    assert_equal "one@example.com", user.email_address
    assert user.errors.of_kind?(:email_address, :taken)
  end

  test "rejects short passwords" do
    user = User.new(email_address: "new@example.com", password: "short")
    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end
end
