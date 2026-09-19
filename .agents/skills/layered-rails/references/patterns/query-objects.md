# Complex queries

- Start with a model scope/class method. Extract recurring composition, complex joins or a distinct read contract.
- Accept a scope and validated parameters; return a relation or declared snapshot. Queries do not persist or publish.
- Parameterize SQL and allowlist dynamic sort columns. Choose indexes from EXPLAIN/workload evidence.
- Filter/paginate before to_a. Check query counts with growing data.
- Operations::QueueSnapshot is an aggregate example; failures must not become successful zero metrics.

Behavior sources: [app/models/operations/queue_snapshot.rb](../../../../../app/models/operations/queue_snapshot.rb), [test/models/queue_snapshot_test.rb](../../../../../test/models/queue_snapshot_test.rb).
