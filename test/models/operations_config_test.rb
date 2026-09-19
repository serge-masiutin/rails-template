require "test_helper"

class OperationsConfigTest < ActiveSupport::TestCase
  test "адреса мониторинга отклоняют опасные схемы, credentials и неверные URL" do
    %w[javascript:alert(1) //metrics.example.com https://user:password@metrics.example.com https://].each do |url|
      assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(logs_url: url) }
    end
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(grafana_url: "https://wrong host") }
    assert_equal "https://logs.example.com", OperationsConfig.new(logs_url: "https://logs.example.com").logs_url
  end

  test "production требует HTTPS для ссылок мониторинга" do
    previous = Rails.env
    Rails.env = "production"
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(prometheus_url: "http://metrics.example.com") }
  ensure
    Rails.env = previous
  end

  test "неполные и слабые credentials отклоняются" do
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(username: "operator", password: nil) }
    assert_raises(Anyway::Config::ValidationError) { OperationsConfig.new(username: "operator", password: "short") }
  end
end
