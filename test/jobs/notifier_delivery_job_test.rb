require "test_helper"

class NotifierDeliveryJobTest < ActiveJob::TestCase
  self.use_transactional_tests = false

  class ProbeNotifier < ApplicationNotifier
    def ping
      notification(body: "Queue probe")
    end
  end

  class ProbeDelivery < ApplicationDelivery
    notifier "NotifierDeliveryJobTest::ProbeNotifier"
    delivers :ping
  end

  def setup
    super
    @previous_mode = AbstractNotifier.delivery_mode
    # Use the Active Job adapter instead of Abstract Notifier's delivery interceptor.
    AbstractNotifier.delivery_mode = :normal
    @delivered = []
    ProbeNotifier.driver = ->(payload) { @delivered << payload.merge(request_id: Current.request_id) }
  end

  def teardown
    AbstractNotifier.delivery_mode = @previous_mode
    Current.reset
    super
  end

  test "notification enqueues after commit and preserves request_id" do
    Current.request_id = "notifier-request"
    User.transaction do
      User.count
      assert_no_enqueued_jobs { ProbeDelivery.ping.deliver_later }
    end

    assert_enqueued_jobs 1, only: NotifierDeliveryJob
    assert_equal "notifiers", enqueued_jobs.last.fetch(:queue)
    assert_equal "notifier-request", enqueued_jobs.last.fetch("request_id")
    Current.reset
    perform_enqueued_jobs(only: NotifierDeliveryJob)
    assert_equal [ { body: "Queue probe", request_id: "notifier-request" } ], @delivered
    assert_nil Current.request_id
  end

  test "rollback cancels notification" do
    assert_no_enqueued_jobs do
      User.transaction do
        User.count
        ProbeDelivery.ping.deliver_later
        raise ActiveRecord::Rollback
      end
    end
    assert_empty @delivered
  end
end
