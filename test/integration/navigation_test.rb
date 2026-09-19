require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "гость не видит профиль" do
    get account_path
    assert_redirected_to new_session_path
  end

  test "Native получает общий контент без web navigation" do
    sign_in_as users(:one)
    get root_path, headers: { "User-Agent" => "StarterApp; Hotwire Native Android; Turbo Native Android" }
    assert_response :success
    assert_select "h1", "Workspace"
    assert_select "nav", count: 0
  end

  test "подмена Native user agent не даёт доступ" do
    get account_path, headers: { "User-Agent" => "Hotwire Native Android" }
    assert_redirected_to new_session_path
  end

  test "веб показывает навигацию" do
    sign_in_as users(:one)
    get root_path
    assert_select "nav", count: 1
  end
end
