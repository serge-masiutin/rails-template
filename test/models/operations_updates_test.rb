require "test_helper"

class OperationsUpdatesTest < ActiveSupport::TestCase
  include ActionCable::TestHelper
  self.use_transactional_tests = false

  class ProbeJob < ApplicationJob
    def perform; end
  end

  setup { SolidQueue::Job.delete_all }
  teardown { SolidQueue::Job.delete_all }

  test "enqueue claim finish retry and discard publish only after commit" do
    job = nil
    assert_signal { job = SolidQueue::Job.enqueue(ProbeJob.new) }
    claimed = nil
    assert_signal { claimed = SolidQueue::ReadyExecution.claim([ "default" ], 1, 1).first }
    assert_signal { claimed.perform }
    assert job.reload.finished?

    job = SolidQueue::Job.enqueue(ProbeJob.new)
    claimed = SolidQueue::ReadyExecution.claim([ "default" ], 1, 1).first
    assert_signal { claimed.failed_with(ArgumentError.new("PRIVATE_ERROR")) }
    assert_signal { job.reload.failed_execution.retry }
    assert_signal { job.reload.discard }
    refute_includes broadcasts(Operations::Updates::STREAM).join, "PRIVATE_ERROR"
  end

  test "rollback and empty claim publish no updates" do
    assert_no_broadcasts(Operations::Updates::STREAM) do
      SolidQueue::Job.transaction do
        SolidQueue::Job.enqueue(ProbeJob.new)
        raise ActiveRecord::Rollback
      end
      SolidQueue::ReadyExecution.claim([ "default" ], 1, 1)
    end
  end

  test "bulk enqueue dispatch and discard preserve update signals" do
    previous = ProbeJob.queue_adapter
    ProbeJob.queue_adapter = :solid_queue
    assert_signal { ActiveJob.perform_all_later([ ProbeJob.new, ProbeJob.new ]) }
    assert_signal { SolidQueue::ReadyExecution.discard_all_in_batches }
    SolidQueue::Job.enqueue(ProbeJob.new, scheduled_at: 1.hour.from_now)
    travel 2.hours do
      assert_signal { SolidQueue::ScheduledExecution.dispatch_next_batch(10) }
    end
  ensure
    ProbeJob.queue_adapter = previous
  end

  private

  def assert_signal(&block)
    assert_changes -> { broadcasts(Operations::Updates::STREAM).size }, &block
    assert_includes broadcasts(Operations::Updates::STREAM).last, "operations_refresh"
    assert_includes broadcasts(Operations::Updates::STREAM).last, "queue"
  end
end
