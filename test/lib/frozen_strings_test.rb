require "test_helper"

class FrozenStringsTest < ActiveSupport::TestCase
  test "project string literals are frozen without a magic comment" do
    literal = "Application string"
    assert_predicate literal, :frozen?
    assert_raises(FrozenError) { literal << "!" }
    assert_equal "Application string!", +literal << "!"
  end
end
