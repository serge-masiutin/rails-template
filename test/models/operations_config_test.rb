require "test_helper"

class OperationsConfigTest < ActiveSupport::TestCase
  test "monitoring addresses reject unsafe schemes credentials and invalid URLs" do
    %w[javascript:alert(1) //metrics.example.com https://user:password@metrics.example.com https://].each do |url|
      assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(logs_url: url) }
    end
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(grafana_url: "https://wrong host") }
    assert_equal "https://logs.example.com", OperationsConfig.new(logs_url: "https://logs.example.com").logs_url
  end

  test "production monitoring links require HTTPS" do
    previous = Rails.env
    Rails.env = "production"
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(prometheus_url: "http://metrics.example.com") }
  ensure
    Rails.env = previous
  end

  test "partial and weak credentials are rejected" do
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(username: "operator", password: nil) }
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(username: "operator", password: "short") }
  end
end
