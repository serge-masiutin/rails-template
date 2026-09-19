require "test_helper"

class Realtime::HttpBroadcasterTest < ActiveSupport::TestCase
  test "публикация передаёт токен заголовком и не сохраняет payload в логах" do
    adapter = Realtime::HttpBroadcaster.new(url: "https://cable.example.test/_broadcast", secret: "test-token")
    request = stub_request(:post, "https://cable.example.test/_broadcast")
      .with(headers: { "Authorization" => "Bearer test-token" }, body: '{"private":"message"}')
      .to_return(status: 201)
    io = StringIO.new
    appender = SemanticLogger.add_appender(io: io, formatter: Observability::JsonFormatter.new)
    adapter.raw_broadcast('{"private":"message"}')
    SemanticLogger.flush
    assert_requested request, times: 1
    assert_not_includes io.string, "private"
    assert_not_includes io.string, "test-token"
  ensure
    SemanticLogger.remove_appender(appender) if appender
  end

  test "ошибка сервера не скрывается и не повторяет запрос" do
    request = stub_request(:post, "https://cable.example.test/_broadcast").to_return(status: 503, body: "private error")
    adapter = Realtime::HttpBroadcaster.new(url: "https://cable.example.test/_broadcast", secret: "test-token")
    error = assert_raises(Realtime::HttpBroadcaster::Error) { adapter.raw_broadcast("{}") }
    assert_not_includes error.message, "private error"
    assert_requested request, times: 1
  end
end
