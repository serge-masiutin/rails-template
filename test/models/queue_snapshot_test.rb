require "test_helper"

class QueueSnapshotTest < ActiveSupport::TestCase
  class ProbeJob < ApplicationJob
    def perform
      raise ArgumentError, "Проверка отказа"
    end
  end

  test "число SQL-запросов диагностики не растёт вместе с очередью" do
    populate = ->(count) do
      SolidQueue::Job.delete_all
      count.times { SolidQueue::Job.enqueue(ProbeJob.new) }
    end

    assert_perform_constant_number_of_queries(populate: populate, scale_factors: [ 2, 10 ]) do
      snapshot = Operations::QueueSnapshot.capture
      assert_equal current_scale, snapshot.fetch(:jobs).fetch(:ready)
    end
  end

  test "видит ожидающие, отложенные и упавшие задания из общей БД" do
    ready = SolidQueue::Job.enqueue(ProbeJob.new)
    ready.ready_execution.update!(created_at: 2.minutes.ago)
    SolidQueue::Job.enqueue(ProbeJob.new, scheduled_at: 1.hour.from_now)
    failed = SolidQueue::Job.enqueue(ProbeJob.new)
    claimed = SolidQueue::ReadyExecution.claim([ "default" ], 2, 1)
    failed_execution = claimed.find { |execution| execution.job_id == failed.id }
    assert_raises(ArgumentError) { failed_execution.perform }
    # Освобождаем вторую задачу, чтобы проверить возраст готовой очереди.
    claimed.find { |execution| execution.job_id == ready.id }.release
    ready.reload.ready_execution.update!(created_at: 2.minutes.ago)

    snapshot = Operations::QueueSnapshot.capture
    assert_equal 1, snapshot.fetch(:jobs).fetch(:ready)
    assert_equal 1, snapshot.fetch(:jobs).fetch(:scheduled)
    assert_equal 1, snapshot.fetch(:jobs).fetch(:failed)
    assert_operator snapshot.fetch(:oldest_ready_age_seconds), :>=, 120
  end
end
