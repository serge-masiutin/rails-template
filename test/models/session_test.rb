require "test_helper"

class SessionTest < ActiveJob::TestCase
  self.use_transactional_tests = false

  setup { @session = users(:one).sessions.create! }
  teardown { @session.destroy! if @session.persisted? }

  test "отключение WebSocket ставится в очередь только после commit отзыва" do
    Session.transaction do
      assert_no_enqueued_jobs { @session.revoke! }
      assert_not Session.exists?(@session.id)
    end
    assert_enqueued_with(job: DisconnectSessionsJob, args: [ [ @session.id ] ])
  end

  test "rollback сохраняет сессию и отменяет отключение" do
    assert_no_enqueued_jobs do
      Session.transaction do
        @session.revoke!
        raise ActiveRecord::Rollback
      end
    end
    assert Session.exists?(@session.id)
  end
end
