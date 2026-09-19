require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "user can view only their own account" do
    assert UserPolicy.new(users(:one), user: users(:one)).apply(:show?)
    assert_not UserPolicy.new(users(:two), user: users(:one)).apply(:show?)
  end

  test "unknown rules and missing users are contract errors" do
    policy = UserPolicy.new(users(:one), user: users(:one))
    assert_raises(ActionPolicy::UnknownRule) { policy.resolve_rule(:publish?) }
    assert_raises(ActionPolicy::AuthorizationContextMissing) { UserPolicy.new(users(:one), user: nil) }
  end
end
