require "test_helper"

class NativeConfigurationTest < ActionDispatch::IntegrationTest
  test "public configuration needs no session and matches bundled JSON" do
    get "/configurations/android_v1.json"
    assert_response :success
    assert_equal JSON.parse(Rails.root.join("native/android/app/src/main/assets/json/android_v1.json").read), response.parsed_body
    assert_equal({}, response.parsed_body.fetch("settings"))
  end

  test "account is modal with no pull-to-refresh and sign-in uses regular navigation" do
    rules = JSON.parse(Rails.root.join("public/configurations/android_v1.json").read).fetch("rules")
    assert_equal "modal", properties_for(rules, "/account").fetch("context")
    assert_equal false, properties_for(rules, "/passwords/new").fetch("pull_to_refresh_enabled")
    assert_equal "default", properties_for(rules, "/session/new").fetch("context")
  end

  private
    def properties_for(rules, path)
      rules.each_with_object({}) do |rule, properties|
        properties.merge!(rule.fetch("properties")) if rule.fetch("patterns").any? { |pattern| Regexp.new(pattern).match?(path) }
      end
    end
end
