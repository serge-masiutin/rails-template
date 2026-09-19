require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "нормализует email и отклоняет дубликаты" do
    user = User.new(email_address: " ONE@EXAMPLE.COM ", password: "valid-password-2026")
    assert_not user.valid?
    assert_equal "one@example.com", user.email_address
    assert user.errors.of_kind?(:email_address, :taken)
  end

  test "отклоняет короткий пароль" do
    user = User.new(email_address: "new@example.com", password: "short")
    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end
end
