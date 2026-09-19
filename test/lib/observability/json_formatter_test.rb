require "test_helper"

class Observability::JsonFormatterTest < ActiveSupport::TestCase
  test "error preserves class and stack without arbitrary content or secrets" do
    io = StringIO.new
    appender = SemanticLogger.add_appender(io: io, formatter: Observability::JsonFormatter.new)
    error = ArgumentError.new("private-user@example.com secret-token")
    error.set_backtrace([ "app/jobs/example_job.rb:10" ])
    Rails.logger.error(message: "Error private-user@example.com", exception: error,
      payload: { password: "top-secret", nested: { email: "private-user@example.com" }, job_id: "job-123" })
    SemanticLogger.flush
    record = JSON.parse(io.string.lines.last)
    assert_equal "ArgumentError", record.dig("exception", "name")
    assert_equal [ "app/jobs/example_job.rb:10" ], record.dig("exception", "stack_trace")
    assert_equal "job-123", record.dig("payload", "job_id")
    refute_includes io.string, "top-secret"
    refute_includes io.string, "private-user@example.com"
    refute_includes io.string, "secret-token"
  ensure
    SemanticLogger.remove_appender(appender) if appender
  end
end
