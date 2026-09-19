require "test_helper"

class Ui::NoticeComponentTest < ViewComponent::TestCase
  test "escapes text and announces the message to screen readers" do
    render_inline Ui::NoticeComponent.new(message: "<script>alert(1)</script>")
    assert_selector "[role=status]", text: "<script>alert(1)</script>"
    assert_no_selector "script"
  end

  test "error has the alert role" do
    render_inline Ui::NoticeComponent.new(message: "Error", variant: :alert)
    assert_selector "[role=alert]", text: "Error"
  end

  test "unknown variant violates the contract" do
    assert_raises(KeyError) { Ui::NoticeComponent.new(message: "Text", variant: :unknown) }
  end
end
