# JSON contracts

- Identify the consumer: product HTML, versioned Native configuration or private sanitized AgentPrism data.
- Select fields explicitly and define version, nullability, types, units and timezone. Never expose an entire Active Record model.
- Validate external SDK input before conversion; fetch required fields directly. Reject unknown statuses, malformed dates and size violations.
- Change backend and consumer decoder together. Keep public Android configuration compatible with released clients.
- Test sensitive extra fields, malformed input, pagination, size and access.

Behavior sources: [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb), [app/frontend/agents/trace-page.ts](../../../../../app/frontend/agents/trace-page.ts), [test/models/agent_trace/document_test.rb](../../../../../test/models/agent_trace/document_test.rb), [public/configurations/android_v1.json](../../../../../public/configurations/android_v1.json).
