module AgentTraceTestHelper
  def trace_payload
    trace = ActiveAgents::Telemetry::Trace.new
    root = trace.span("PRIVATE_TITLE", type: "root", start_time: 1.second.ago)
    root.set_attribute("agent.class", "TestAgent")
    root.set_attribute("agent.action", "summarize")
    root.set_attribute("starterapp.prompt_version", "v1")
    root.set_attribute("starterapp.request_id", "request-123")
    root.set_attribute("prompt.input.messages", "PRIVATE_PROMPT")
    root.set_attribute("api_key", "PRIVATE_KEY")
    llm = root.add_span("PRIVATE_TITLE", type: "llm")
    llm.set_attribute("llm.output.message", "PRIVATE_OUTPUT")
    tool = llm.add_span("PRIVATE_TITLE", type: "tool")
    tool.set_attribute("tool.name", "lookup_record")
    tool.set_attribute("tool.input.args", "PRIVATE_ARGUMENTS")
    tool.record_error(ArgumentError.new("PRIVATE_ERROR"))
    tool.finish
    llm.set_status(:ok)
    llm.finish
    root.set_status(:ok)
    root.finish
    trace.to_h
  end

  def capture_trace
    AgentTrace::Capture.call(trace_payload, {})
    AgentTrace.order(:id).last
  end

  def operator_credentials
    @previous_operations = Rails.configuration.x.operations
    Rails.configuration.x.operations = OperationsConfig.new(username: "operator", password: "p" * 32)
    ActionController::HttpAuthentication::Basic.encode_credentials("operator", "p" * 32)
  end
end
