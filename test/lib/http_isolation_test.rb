require "test_helper"
require "net/http"

class HttpIsolationTest < ActiveSupport::TestCase
  test "unstubbed external HTTP is blocked before network IO" do
    assert_raises(WebMock::NetConnectNotAllowedError) do
      Net::HTTP.get(URI("https://unmocked.example.invalid/contract"))
    end
  end
end
