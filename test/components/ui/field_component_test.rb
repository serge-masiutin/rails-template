require "test_helper"

class Ui::FieldComponentTest < ViewComponent::TestCase
  test "keeps Rails names and IDs together with email input constraints" do
    form = ActionView::Helpers::FormBuilder.new(:credentials, nil, vc_test_view_context, {})
    render_inline Ui::FieldComponent.new(form: form, attribute: :email_address, label: "Email",
      type: :email, value: "member@example.test", required: true, autofocus: true, autocomplete: "username")

    assert_selector 'label[for="credentials_email_address"]', text: "Email"
    assert_selector 'input#credentials_email_address[type="email"][name="credentials[email_address]"][required][autofocus][autocomplete="username"][value="member@example.test"]'
    assert_no_selector "input[aria-invalid], input[aria-describedby]"
  end

  test "associates escaped hints and errors with the password without a live announcement" do
    form = ActionView::Helpers::FormBuilder.new(nil, nil, vc_test_view_context, {})
    render_inline Ui::FieldComponent.new(form: form, attribute: :password, label: "Password",
      type: :password, autocomplete: "new-password", minlength: 12, maxlength: 72,
      hint: "Use at least 12 characters.", error: "<script>Invalid</script>")

    assert_selector 'label[for="password"]', text: "Password"
    assert_selector 'input#password[name="password"][type="password"][autocomplete="new-password"][minlength="12"][maxlength="72"][aria-invalid="true"][aria-describedby="password-hint password-error"]'
    assert_selector "#password-hint", text: "Use at least 12 characters."
    assert_selector "#password-error", text: "<script>Invalid</script>"
    assert_no_selector "script, [role=alert], input[value]"
  end

  test "retains a model-bound email unless the form explicitly overrides it" do
    user = User.new(email_address: "bound@example.test")
    form = ActionView::Helpers::FormBuilder.new(:user, user, vc_test_view_context, {})
    render_inline Ui::FieldComponent.new(form: form, attribute: :email_address, label: "Email", type: :email)

    assert_selector 'input[name="user[email_address]"][value="bound@example.test"]'
  end

  test "omits an empty error from valid fields" do
    form = ActionView::Helpers::FormBuilder.new(nil, nil, vc_test_view_context, {})
    render_inline Ui::FieldComponent.new(form: form, attribute: :password, label: "Password", type: :password, error: "")

    assert_no_selector "[aria-invalid], [aria-describedby], #password-error"
  end

  test "rejects a control type outside the supported contract" do
    form = ActionView::Helpers::FormBuilder.new(nil, nil, vc_test_view_context, {})
    assert_raises(KeyError) do
      Ui::FieldComponent.new(form: form, attribute: :email_address, label: "Email", type: :textarea)
    end
  end

  test "renders the email Lookbook example" do
    render_preview(:email)
    assert_selector 'input[type="email"][aria-describedby="preview_email_address-hint"]'
  end

  test "renders the password Lookbook example" do
    render_preview(:password)
    assert_selector 'input[type="password"][minlength="12"]'
  end

  test "renders the invalid password Lookbook example" do
    render_preview(:invalid_password)
    assert_selector 'input[aria-invalid="true"][aria-describedby="preview_password-error"]'
  end
end
