require "test_helper"

class Ui::NoticeComponentTest < ViewComponent::TestCase
  test "экранирует текст и объявляет сообщение для screen reader" do
    render_inline Ui::NoticeComponent.new(message: "<script>alert(1)</script>")
    assert_selector "[role=status]", text: "<script>alert(1)</script>"
    assert_no_selector "script"
  end

  test "ошибка имеет роль alert" do
    render_inline Ui::NoticeComponent.new(message: "Ошибка", variant: :alert)
    assert_selector "[role=alert]", text: "Ошибка"
  end

  test "неизвестный вариант нарушает контракт" do
    assert_raises(KeyError) { Ui::NoticeComponent.new(message: "Текст", variant: :unknown) }
  end
end
