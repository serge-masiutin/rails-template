# Review overloaded models

1. Find public methods, data, callers and tests. Do not invent churn when history is unavailable.
2. Group independent invariants, dependencies and reasons to change. File length alone does not justify extraction.
3. Keep natural model behavior in place; put stable independent roles in its namespace. Do not split concerns by Rails macro type.
4. Move one role at a time, preserving public journeys and tests.

Report what obstructs a concrete change, the responsibility to extract and how behavior preservation is verified.

Behavior sources: [app/models/agent_trace.rb](../../../../app/models/agent_trace.rb), [app/models/agent_trace/document.rb](../../../../app/models/agent_trace/document.rb), [docs/architecture.md](../../../../docs/architecture.md).
