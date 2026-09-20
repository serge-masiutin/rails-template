require "test_helper"

class Observability::HealthTest < ActiveSupport::TestCase
  class ProbeJob < ApplicationJob
    def perform
      raise ArgumentError, "Failure probe"
    end
  end

  test "diagnostic SQL query count stays constant as the queue grows" do
    populate = ->(count) do
      SolidQueue::Job.delete_all
      count.times { SolidQueue::Job.enqueue(ProbeJob.new) }
    end

    assert_perform_constant_number_of_queries(populate: populate, scale_factors: [ 2, 10 ]) do
      snapshot = Observability::Health.queue_snapshot
      assert_equal current_scale, snapshot.fetch(:jobs).fetch(:ready)
    end
  end

  test "reads ready scheduled and failed jobs from the shared database" do
    ready = SolidQueue::Job.enqueue(ProbeJob.new)
    ready.ready_execution.update!(created_at: 2.minutes.ago)
    SolidQueue::Job.enqueue(ProbeJob.new, scheduled_at: 1.hour.from_now)
    failed = SolidQueue::Job.enqueue(ProbeJob.new)
    claimed = SolidQueue::ReadyExecution.claim([ "default" ], 2, 1)
    failed_execution = claimed.find { |execution| execution.job_id == failed.id }
    assert_raises(ArgumentError) { failed_execution.perform }
    claimed.find { |execution| execution.job_id == ready.id }.release
    ready.reload.ready_execution.update!(created_at: 2.minutes.ago)

    snapshot = Observability::Health.queue_snapshot
    assert_equal 1, snapshot.fetch(:jobs).fetch(:ready)
    assert_equal 1, snapshot.fetch(:jobs).fetch(:scheduled)
    assert_equal 1, snapshot.fetch(:jobs).fetch(:failed)
    assert_operator snapshot.fetch(:oldest_ready_age_seconds), :>=, 120
  end
end
