require "test_helper"

class AuthenticationContractTest < ActionDispatch::IntegrationTest
  test "обязательные поля проверяются на HTTP-границе" do
    post session_path, params: { email_address: users(:one).email_address }
    assert_response :bad_request
  end

  test "успешный вход использует 303 и возвращает к исходному пути" do
    get account_path
    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_response :see_other
    assert_redirected_to account_path
  end

  test "HEAD сохраняет адрес страницы для возврата после входа" do
    head account_path
    assert_response :see_other
    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_redirected_to account_path
  end

  test "сброс пароля отзывает старые сессии" do
    user = users(:one)
    user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    put password_path(user.password_reset_token), params: { password: "a-new-password-2026", password_confirmation: "a-new-password-2026" }
    assert_response :see_other
    assert_empty user.sessions.reload
  end

  test "ограничение частоты входа и восстановления использует 303" do
    [ session_path, passwords_path ].each do |path|
      11.times do
        post path, params: { email_address: users(:one).email_address, password: "password" }
      end
      assert_response :see_other
      assert_equal "Try again later.", flash[:alert]
    end
  end

  test "недействительный токен при смене пароля перенаправляет через 303" do
    put password_path("invalid-token"), params: { password: "new-password-2026", password_confirmation: "new-password-2026" }
    assert_response :see_other
    assert_redirected_to new_password_path
  end

  test "выход с истёкшей сессией перенаправляет на вход через 303" do
    delete session_path
    assert_response :see_other
    assert_redirected_to new_session_path

    post session_path, params: { email_address: users(:one).email_address, password: "password" }
    assert_redirected_to root_path
  end
end
