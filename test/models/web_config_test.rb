require "test_helper"

class WebConfigTest < ActiveSupport::TestCase
  test "отклоняет URL вместо hostname" do
    assert_raises(Anyway::Config::ValidationError) { WebConfig.new(host: "https://example.com/path") }
  end

  test "отклоняет неизвестный протокол" do
    assert_raises(Anyway::Config::ValidationError) { WebConfig.new(protocol: "ftp") }
  end
end
