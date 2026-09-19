require "test_helper"

class Observability::ErrorSubscriberTest < ActiveSupport::TestCase
  test "Rails.error попадает в журнал без произвольного контекста" do
    io = StringIO.new
    appender = SemanticLogger.add_appender(io: io, formatter: Observability::JsonFormatter.new)
    Current.set(request_id: "error-request") do
      Rails.error.report(ArgumentError.new("секрет"), handled: true, severity: :warning,
        context: { email: "private@example.com" }, source: "starterapp.test")
    end
    SemanticLogger.flush
    record = JSON.parse(io.string.lines.last)
    assert_equal "warn", record.fetch("level")
    assert_equal "error-request", record.dig("named_tags", "request_id")
    assert_equal "error.reported", record.dig("payload", "event")
    assert_equal "starterapp.test", record.dig("payload", "source")
    refute_includes io.string, "private@example.com"
    refute_includes io.string, "секрет"
  ensure
    SemanticLogger.remove_appender(appender) if appender
  end
end
