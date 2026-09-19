require "test_helper"
require_relative "../../test_helpers/agent_trace_test_helper"

class AgentTrace::DocumentTest < ActiveSupport::TestCase
  include AgentTraceTestHelper
  self.use_transactional_tests = false
  setup { AgentTrace.delete_all }
  teardown { AgentTrace.delete_all }

  test "сохраняет дерево SDK и удаляет произвольные тексты во всех узлах" do
    document = AgentTrace::Document.new(trace_payload).attributes.fetch(:document)
    assert_equal 3, document.dig(:traceRecord, :spansCount)
    root = document.fetch(:spans).first
    assert_equal "TestAgent.summarize", root.fetch(:title)
    tool = root.fetch(:children).first.fetch(:children).first
    assert_equal "tool.lookup_record", tool.fetch(:title)
    assert_equal "error", tool.fetch(:status)
    assert_includes tool.fetch(:attributes), { key: "error.type", value: { stringValue: "ArgumentError" } }
    refute_includes document.to_json, "PRIVATE_"
    refute document.fetch(:traceRecord).key?(:totalTokens)
    refute document.fetch(:traceRecord).key?(:totalCost)
  end

  test "ошибочные и слишком большие графы не превращаются в пустые трассы" do
    invalid = []
    invalid << trace_payload.tap { |trace| trace.fetch("spans").last["parent_span_id"] = "missing" }
    invalid << trace_payload.tap { |trace| trace.fetch("spans") << trace.fetch("spans").first.dup }
    invalid << trace_payload.tap { |trace| trace["spans"] *= 100 }
    invalid << trace_payload.tap { |trace| trace.fetch("spans").last["end_time"] = "invalid" }
    invalid << trace_payload.tap { |trace| trace.fetch("spans").last["type"] = "new_sdk_type" }
    invalid << trace_payload.tap { |trace| trace.fetch("spans").last.fetch("attributes")["tool.name"] = "<script>" }
    invalid.each { |trace| assert_raises(AgentTrace::Document::InvalidTrace) { AgentTrace::Document.new(trace).attributes } }
  end

  test "очистка удаляет только трассы старше семи дней" do
    fresh = capture_trace
    expired = capture_trace
    expired.update!(started_at: 8.days.ago)
    AgentTrace.prune
    assert AgentTrace.exists?(fresh.id)
    refute AgentTrace.exists?(expired.id)
  end

  test "сбой записи наблюдаем и не повторяет генерацию" do
    previous = Yabeda.starterapp.agent_trace_failures.get(stage: "storage") || 0
    payload = trace_payload
    AgentTrace::Capture.call(payload, {})
    assert_no_difference "AgentTrace.count" do
      AgentTrace::Capture.call(payload, {})
    end
    assert_equal previous + 1, Yabeda.starterapp.agent_trace_failures.get(stage: "storage")
  end
end
