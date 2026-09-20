require "test_helper"

class NavigationTest < ActionDispatch::IntegrationTest
  test "Native receives shared content without web navigation" do
    sign_in_as users(:one)
    get root_path, headers: { "User-Agent" => "StarterApp; Hotwire Native Android; Turbo Native Android" }
    assert_response :success
    assert_select "h1", "Workspace"
    assert_select 'nav[aria-label="Main navigation"]', count: 0
    assert_select "a[href=?]", account_path, text: "Open profile"
  end

  test "forged Native User-Agent grants no access" do
    get account_path, headers: { "User-Agent" => "Hotwire Native Android" }
    assert_redirected_to new_session_path
  end

  test "web displays navigation" do
    sign_in_as users(:one)
    get root_path
    assert_select 'nav[aria-label="Main navigation"]' do
      assert_select "a[href=?]", account_path, text: "Profile"
    end
  end
end
