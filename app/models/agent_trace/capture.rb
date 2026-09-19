class AgentTrace::Capture
  def self.call(trace, _sdk)
    attributes = AgentTrace::Document.new(trace).attributes
    AgentTrace.connection_pool.with_connection { AgentTrace.create!(attributes) }
  rescue ActiveRecord::ActiveRecordError, AgentTrace::Document::InvalidTrace => error
    # A diagnostic failure must not repeat an already paid generation.
    Yabeda.starterapp.agent_trace_failures.increment(stage: "storage")
    Rails.error.report(error, handled: true, severity: :error, source: "agent_trace")
  end
end
