require "test_helper"

class FrozenStringsTest < ActiveSupport::TestCase
  test "строки проекта заморожены без magic comment" do
    literal = "Строка приложения"
    assert_predicate literal, :frozen?
    assert_raises(FrozenError) { literal << "!" }
    assert_equal "Строка приложения!", +literal << "!"
  end
end
