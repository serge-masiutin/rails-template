require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "user can view only their own account" do
    assert UserPolicy.new(users(:one), user: users(:one)).apply(:show?)
    assert_not UserPolicy.new(users(:two), user: users(:one)).apply(:show?)
  end
end
