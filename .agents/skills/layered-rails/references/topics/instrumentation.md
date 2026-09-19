# Logs, metrics and traces

- Reuse Rails.logger, Rails.error, ActiveSupport::Notifications and Yabeda. Subscribers separate formatting/measurement from domain operations.
- Events use stable names, statuses, durations and technical IDs. Request/job IDs belong in log fields; metric/Loki labels use bounded sets.
- Preserve exception causes/stacks. Never interpolate arbitrary exception messages, user text, tokenized URLs, params, documents or keys into log messages.
- JsonFormatter redacts known sensitive fields, not arbitrary constructed strings. Test negative cases with secret markers.
- Ordinary logs go through rotated JSON files/stdout and Alloy/Loki, not PostgreSQL. Suppress only successful health/metrics request summaries; retain failures and denied access.
- Web/jobs have separate metric endpoints. WorkerMetrics aggregates forked worker counters. Queue gauges read shared storage and must not be summed across web instances.
- Update dashboards, alerts and promtool cases with metric changes. Initial thresholds are not measured production SLOs.
- AI traces use AgentTrace::Document allowlisting and retention. Diagnostic loss must be observable without repeating a paid generation.

Behavior sources: [docs/observability.md](../../../../../docs/observability.md), [lib/observability/json_formatter.rb](../../../../../lib/observability/json_formatter.rb), [lib/observability/agent_subscriber.rb](../../../../../lib/observability/agent_subscriber.rb), [test/lib/observability/json_formatter_test.rb](../../../../../test/lib/observability/json_formatter_test.rb).
