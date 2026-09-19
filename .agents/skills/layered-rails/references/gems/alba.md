# Explicit serialization without another DSL

- Product screens return HTML. JSON serves Native configuration, operations views or a specific API consumer.
- Build a Hash from allowed fields; never expose an entire model with as_json. Specify types, nullability, time units and version.
- AgentTrace::Document and decodeTracePage demonstrate a Ruby contract validated by TypeScript at entry.
- Standard Ruby/JSON and a focused conversion object suffice for small contracts. Add a serializer gem only for demonstrated recurring complexity.
- Check extra/missing fields, malformed values, permissions, collection limits and consumer compatibility.

Behavior sources: [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb), [app/frontend/agents/trace-page.ts](../../../../../app/frontend/agents/trace-page.ts), [docs/hotwire.md](../../../../../docs/hotwire.md).
