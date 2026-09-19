# Explicit domain operations

- One operation implements one use case with one public entrypoint. Place it in the model namespace when it outgrows a natural model method.
- Pass actor, record and validated parameters explicitly. Do not add generic app/services or ApplicationService merely to standardize call.
- Make transaction, external IO, enqueue and result boundaries visible. Constructors do not execute work.
- Do not convert domain failures into false/null without a contract. Rails validation false is valid when errors remain available and the consumer renders 422.
- User#reset_password fits its model; AgentTrace::Capture is a separate diagnostic persistence boundary with observable failure.
- Test public results and rollback, not private helper ordering.

Behavior sources: [app/models/user.rb](../../../../../app/models/user.rb), [app/models/agent_trace/capture.rb](../../../../../app/models/agent_trace/capture.rb), [test/integration/password_reset_atomicity_test.rb](../../../../../test/integration/password_reset_atomicity_test.rb).
