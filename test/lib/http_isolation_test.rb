require "test_helper"
require "net/http"

class HttpIsolationTest < ActiveSupport::TestCase
  test "незамоканный внешний HTTP запрещён до выхода в сеть" do
    assert_raises(WebMock::NetConnectNotAllowedError) do
      Net::HTTP.get(URI("https://unmocked.example.invalid/contract"))
    end
  end
end
