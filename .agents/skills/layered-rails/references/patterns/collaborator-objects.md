# Model-adjacent collaborators

- Extract cohesive behavior into its owner's namespace when it has a contract and an independent reason to change.
- Pass records or validated values explicitly; do not hide Current, request or global SDK dependencies.
- AgentTrace::Document converts external traces; AgentTrace::Capture persists them; AgentTrace owns storage and retention.
- Do not wrap simple attribute access. Test the collaborator contract and one real path through its owner.

Behavior sources: [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb), [app/models/agent_trace/capture.rb](../../../../../app/models/agent_trace/capture.rb).
