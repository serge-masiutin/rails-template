require "test_helper"
require_relative "../test_helpers/agent_trace_test_helper"

class AgentTraceTest < ActiveSupport::TestCase
  include AgentTraceTestHelper
  self.use_transactional_tests = false
  setup { AgentTrace.delete_all }
  teardown { AgentTrace.delete_all }

  test "pruning removes only traces older than seven days" do
    fresh = capture_trace
    expired = capture_trace
    expired.update!(started_at: 8.days.ago)
    AgentTrace.prune
    assert AgentTrace.exists?(fresh.id)
    refute AgentTrace.exists?(expired.id)
  end
end
