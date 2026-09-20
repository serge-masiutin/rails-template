require "test_helper"

class Realtime::OperationsUpdatesTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  ENDPOINT = "https://cable.example.test/_broadcast"

  class ProbeJob < ApplicationJob
    def perform; end
  end

  setup do
    Realtime::OperationsUpdates.flush
    @cable_config = ActionCable.server.config.cable
    @adapter = AnyCable.broadcast_adapter
    ActionCable.server.config.cable = { "adapter" => "any_cable" }
    ActionCable.server.restart
    AnyCable.broadcast_adapter = Realtime::HttpBroadcaster.new(url: ENDPOINT, secret: "test-token")
    @release = Concurrent::Event.new
  end

  teardown do
    @release.set
    Realtime::OperationsUpdates.flush
    ActionCable.server.config.cable = @cable_config
    ActionCable.server.restart
    AnyCable.broadcast_adapter = @adapter
    SolidQueue::Job.where(class_name: ProbeJob.name).delete_all
  end

  test "committed jobs do not wait for HTTP and changes during publication are coalesced" do
    entered = Concurrent::Event.new
    request = stub_request(:post, ENDPOINT).to_return do
      entered.set
      raise Timeout::Error, "Broadcast was not released" unless @release.wait(5)
      { status: 201 }
    end

    job = SolidQueue::Job.enqueue(ProbeJob.new)
    assert entered.wait(5), "No diagnostic broadcast started"
    assert SolidQueue::Job.exists?(job.id)
    10.times { SolidQueue::Job.enqueue(ProbeJob.new) }
    @release.set
    Realtime::OperationsUpdates.flush
    assert_requested request, times: 2
  end

  test "failed publication is reported and does not block subsequent updates" do
    request = stub_request(:post, ENDPOINT).to_return(status: 503).then.to_return(status: 201)
    io = StringIO.new
    appender = SemanticLogger.add_appender(io: io, formatter: Observability::JsonFormatter.new)

    Realtime::OperationsUpdates.publish("queue")
    Realtime::OperationsUpdates.flush
    SemanticLogger.flush
    events = io.string.lines.map { |line| JSON.parse(line) }
    assert events.any? { |event| event.dig("payload", "source") == "operations_updates" }

    Realtime::OperationsUpdates.publish("queue")
    Realtime::OperationsUpdates.flush
    assert_requested request, times: 2
  ensure
    SemanticLogger.remove_appender(appender) if appender
  end

  test "a saturated diagnostic queue reports overflow without blocking the caller" do
    publisher = Realtime::OperationsUpdates.new
    entered = Concurrent::Event.new
    request = stub_request(:post, ENDPOINT).to_return do
      entered.set
      raise Timeout::Error, "Broadcast was not released" unless @release.wait(5)
      { status: 201 }
    end
    publisher.publish("queue")
    assert entered.wait(5)
    64.times { |index| publisher.publish("access", stream: "test:#{index}") }
    assert_error_reported(Concurrent::RejectedExecutionError) do
      publisher.publish("access", stream: "test:overflow")
    end
    @release.set
    publisher.shutdown
    assert_requested request, times: 65
  ensure
    @release.set
    publisher&.shutdown
  end
end
