require "test_helper"

class Ui::SubmitComponentTest < ViewComponent::TestCase
  test "uses a native Rails submit control with an escaped label" do
    form = ActionView::Helpers::FormBuilder.new(nil, nil, vc_test_view_context, {})
    render_inline Ui::SubmitComponent.new(form: form, label: "<Save>")

    assert_selector 'input[type="submit"][name="commit"][value="<Save>"]:not([disabled])'
    assert_no_selector "save"
  end

  test "supports unavailable and Turbo submitting states without changing form submission" do
    form = ActionView::Helpers::FormBuilder.new(nil, nil, vc_test_view_context, {})
    render_inline Ui::SubmitComponent.new(form: form, label: "Save", disabled: true, submitting_label: "Saving…")

    assert_selector 'input[type="submit"][disabled][data-turbo-submits-with="Saving…"]'
  end

  test "renders the ready Lookbook example" do
    render_preview(:ready)
    assert_selector 'input[type="submit"]:not([disabled])'
  end

  test "renders the disabled Lookbook example" do
    render_preview(:disabled)
    assert_selector 'input[type="submit"][disabled]'
  end
end
