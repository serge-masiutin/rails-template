require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_select 'input#email_address[name="email_address"][type="email"][required][autofocus][autocomplete="username"][value=?]', @user.email_address
    assert_select 'label[for="email_address"]', text: "Email"
    assert_select 'input#password[name="password"][type="password"][required][maxlength="72"][autocomplete="current-password"]'
    assert_select "input#password[value]", count: 0
    assert_select 'form[action=?] input[type="submit"][value="Sign in"]', session_path
  end
end
