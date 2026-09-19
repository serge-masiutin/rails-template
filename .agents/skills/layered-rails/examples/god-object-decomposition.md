# Separate independent model roles

Group methods by invariants and data, not line count. Extract a stable responsibility into the model namespace. AgentTrace stores/prunes, Document validates/converts and Capture persists with a failure policy. Do not split a small User model for hypothetical growth.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/models/agent_trace.rb](../../../../app/models/agent_trace.rb), [app/models/agent_trace/document.rb](../../../../app/models/agent_trace/document.rb), [app/models/agent_trace/capture.rb](../../../../app/models/agent_trace/capture.rb).
