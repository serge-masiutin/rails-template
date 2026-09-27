require "test_helper"

class SessionDisconnectTest < ActiveJob::TestCase
  self.use_transactional_tests = false

  setup do
    SessionDisconnect.delete_all
    @user = User.create!(email_address: "outbox-test@example.test", password: "old-password-2026")
    @session = @user.sessions.create!
  end

  teardown do
    SessionDisconnect.delete_all
    @user.destroy!
  end

  test "queue rejection cannot lose a committed revocation and the dispatcher recovers it" do
    previous_adapter = DisconnectSessionsJob.queue_adapter
    DisconnectSessionsJob.enable_test_adapter(ActiveJob::QueueAdapters::SolidQueueAdapter.new)
    connection = SolidQueue::Job.connection
    connection.execute("ALTER TABLE solid_queue_jobs ADD CONSTRAINT reject_test_disconnect CHECK (class_name <> 'DisconnectSessionsJob') NOT VALID")

    User.reset_password(token: @user.password_reset_token, password: "new-password-2026", password_confirmation: "new-password-2026")

    assert @user.reload.authenticate("new-password-2026")
    assert_not Session.exists?(@session.id)
    intent = SessionDisconnect.sole
    assert_equal [ @session.id ], intent.session_ids
    connection.execute("ALTER TABLE solid_queue_jobs DROP CONSTRAINT reject_test_disconnect")

    DisconnectSessionsJob.enable_test_adapter(previous_adapter)
    assert_enqueued_with(job: DisconnectSessionsJob, args: [ [ @session.id ], { outbox_id: intent.id } ]) do
      DispatchSessionDisconnectsJob.perform_now
    end
    DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
    assert_not SessionDisconnect.exists?(intent.id)
    assert_no_enqueued_jobs { DispatchSessionDisconnectsJob.perform_now }
    DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
  ensure
    connection&.execute("ALTER TABLE solid_queue_jobs DROP CONSTRAINT IF EXISTS reject_test_disconnect")
    DisconnectSessionsJob.enable_test_adapter(previous_adapter)
  end

  test "a process stopping after commit leaves a recoverable disconnect" do
    # A committed outbox row with no queued job models the commit/enqueue crash window.
    intent = SessionDisconnect.create!(session_ids: [ @session.id ])
    @session.destroy!
    assert_enqueued_with(job: DisconnectSessionsJob, args: [ intent.session_ids, { outbox_id: intent.id } ]) do
      DispatchSessionDisconnectsJob.perform_now
    end
    assert SessionDisconnect.exists?(intent.id)
  end

  test "outbox write failure rolls back session revocation" do
    connection = ApplicationRecord.connection
    connection.execute("ALTER TABLE session_disconnects ADD CONSTRAINT reject_test_intent CHECK (false) NOT VALID")
    assert_raises(ActiveRecord::StatementInvalid) { @session.revoke }
    assert Session.exists?(@session.id)
  ensure
    connection&.execute("ALTER TABLE session_disconnects DROP CONSTRAINT IF EXISTS reject_test_intent")
  end

  test "failed external delivery keeps intent and replay acknowledges only success" do
    intent = SessionDisconnect.create!(session_ids: [ @session.id ])
    cable_config = ActionCable.server.config.cable
    adapter = AnyCable.broadcast_adapter
    ActionCable.server.config.cable = { "adapter" => "any_cable" }
    ActionCable.server.restart
    endpoint = "https://disconnect.example.test/_broadcast"
    AnyCable.broadcast_adapter = Realtime::HttpBroadcaster.new(url: endpoint, secret: "test-token")
    request = stub_request(:post, endpoint).to_return(status: 503).then.to_return(status: 201)

    assert_raises(Realtime::HttpBroadcaster::Error) do
      DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
    end
    assert SessionDisconnect.exists?(intent.id)
    DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
    assert_not SessionDisconnect.exists?(intent.id)
    assert_requested request, times: 2
    DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
    assert_requested request, times: 2
  ensure
    ActionCable.server.config.cable = cable_config
    ActionCable.server.restart
    AnyCable.broadcast_adapter = adapter
  end

  test "delivery repeated after acknowledgement failure preserves the intent until success" do
    intent = SessionDisconnect.create!(session_ids: [ @session.id ])
    connection = ApplicationRecord.connection
    connection.create_table :disconnect_ack_guards do |table|
      table.references :session_disconnect, foreign_key: true
    end
    connection.execute("INSERT INTO disconnect_ack_guards (session_disconnect_id) VALUES (#{Integer(intent.id)})")
    cable_config = ActionCable.server.config.cable
    adapter = AnyCable.broadcast_adapter
    ActionCable.server.config.cable = { "adapter" => "any_cable" }
    ActionCable.server.restart
    endpoint = "https://disconnect.example.test/_broadcast"
    AnyCable.broadcast_adapter = Realtime::HttpBroadcaster.new(url: endpoint, secret: "test-token")
    request = stub_request(:post, endpoint).to_return(status: 201)

    assert_raises(ActiveRecord::InvalidForeignKey) do
      DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
    end
    assert SessionDisconnect.exists?(intent.id)
    assert_requested request, times: 1
    connection.drop_table(:disconnect_ack_guards)
    DisconnectSessionsJob.perform_now(intent.session_ids, outbox_id: intent.id)
    assert_not SessionDisconnect.exists?(intent.id)
    assert_requested request, times: 2
  ensure
    connection&.drop_table(:disconnect_ack_guards, if_exists: true)
    ActionCable.server.config.cable = cable_config
    ActionCable.server.restart
    AnyCable.broadcast_adapter = adapter
  end
end
