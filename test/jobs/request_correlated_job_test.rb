require "test_helper"

class RequestCorrelatedJobTest < ActiveSupport::TestCase
  class ProbeJob < ApplicationJob
    def perform
      Rails.logger.info("Job context probe", payload: { request_id: Current.request_id })
    end
  end

  class FailingJob < ApplicationJob
    def perform
      raise ArgumentError, "Context cleanup probe"
    end
  end

  test "HTTP context survives serialization and clears after execution" do
    io = StringIO.new
    appender = SemanticLogger.add_appender(io: io, formatter: Observability::JsonFormatter.new)
    serialized = Current.set(request_id: "original-request") { ProbeJob.new.serialize }
    Current.set(request_id: "outer-context") do
      ActiveJob::Base.deserialize(serialized).perform_now
      assert_equal "outer-context", Current.request_id
    end
    SemanticLogger.flush
    records = io.string.lines.map { |line| JSON.parse(line) }
    record = records.find { |entry| entry["message"] == "Job context probe" }
    assert_equal "original-request", record.dig("named_tags", "request_id")
    assert_equal serialized.fetch("job_id"), record.dig("named_tags", "job_id")
    completion = records.find { |entry| entry["metric"] == "rails.job.perform" }
    assert_equal serialized.fetch("job_id"), completion.fetch("payload").fetch("job_id")
  ensure
    SemanticLogger.remove_appender(appender) if appender
  end

  test "older jobs without request_id still execute" do
    serialized = ProbeJob.new.serialize.except("request_id")
    assert_nothing_raised { ActiveJob::Base.deserialize(serialized).perform_now }
  end

  test "failed jobs do not leak context into the next job" do
    job = FailingJob.new
    job.request_id = "failed-request"
    Current.set(request_id: "outer-context") do
      assert_raises(ArgumentError) { job.perform_now }
      assert_equal "outer-context", Current.request_id
      refute_equal "failed-request", SemanticLogger.named_tags[:request_id]
    end
  end
end
