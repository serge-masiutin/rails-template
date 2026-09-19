require "test_helper"

class OperationsConfigTest < ActiveSupport::TestCase
  test "неполные и слабые credentials отклоняются" do
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(username: "operator", password: nil) }
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(username: "operator", password: "short") }
  end
end
