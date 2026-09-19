require "test_helper"

class WebConfigTest < ActiveSupport::TestCase
  test "rejects a URL in place of a hostname" do
    assert_raises(Anyway::Config::ValidationError) { WebConfig.new(host: "https://example.com/path") }
  end

  test "rejects unknown protocols" do
    assert_raises(Anyway::Config::ValidationError) { WebConfig.new(protocol: "ftp") }
  end
end
