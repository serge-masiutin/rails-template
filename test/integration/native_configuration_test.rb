require "test_helper"

class NativeConfigurationTest < ActionDispatch::IntegrationTest
  test "an unauthenticated client receives the published JSON configuration" do
    get "/configurations/android_v1.json"
    assert_response :success
    assert_equal "application/json", response.media_type
    assert_equal JSON.parse(Rails.root.join("public/configurations/android_v1.json").read), response.parsed_body
  end
end
