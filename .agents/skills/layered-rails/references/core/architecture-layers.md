# Application layers

- Controllers/channels accept external data, authorize and select responses. Jobs accept serialized arguments and reload records.
- Models own state and invariants. Put a distinct related use case in the model namespace; keep simple CRUD conventional.
- ERB/ViewComponent renders shared web/Android HTML; Stimulus owns local interaction and Kotlin native navigation/device capabilities.
- Configuration, transport, storage and telemetry have explicit boundaries. Domain interfaces do not accept requests, params, cookies or hidden Current.user.
- Do not pass data through empty wrappers. Each extracted object needs a contract and a reason to change.
- Inspect dependency direction through actual calls, not directory names. Report the violation, consumers and smallest fix.

Behavior sources: [docs/architecture.md](../../../../../docs/architecture.md), [app/models/user.rb](../../../../../app/models/user.rb), [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb).
