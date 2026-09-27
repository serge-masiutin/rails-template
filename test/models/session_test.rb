require "test_helper"

class SessionTest < ActiveJob::TestCase
  self.use_transactional_tests = false

  setup { @session = users(:one).sessions.create! }
  teardown do
    @session.destroy! if @session.persisted?
    SessionDisconnect.delete_all
  end

  test "WebSocket disconnect enqueues only after revocation commits" do
    Session.transaction do
      assert_no_enqueued_jobs { @session.revoke }
      assert_not Session.exists?(@session.id)
      assert_equal [ @session.id ], SessionDisconnect.sole.session_ids
    end
    assert_enqueued_with(job: DisconnectSessionsJob, args: [ [ @session.id ], { outbox_id: SessionDisconnect.sole.id } ])
  end

  test "rollback preserves the session and cancels disconnect" do
    assert_no_enqueued_jobs do
      Session.transaction do
        @session.revoke
        raise ActiveRecord::Rollback
      end
    end
    assert Session.exists?(@session.id)
    assert_empty SessionDisconnect.all
  end
end
