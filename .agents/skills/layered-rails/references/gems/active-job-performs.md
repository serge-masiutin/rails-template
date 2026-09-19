# Active Job and Solid Queue boundaries

- An explicit app/jobs class owns the queue boundary, arguments and failure policy; even a short job can serve this contract.
- Inherit ApplicationJob and delegate from perform. Pass IDs, not request, Current.user, documents or secrets.
- Enqueue-after-commit is enabled. Test rollback and execution failure instead of generating hidden model jobs.
- Add retry_on, concurrency limits and timeouts locally for a concrete reason; establish idempotency first.
- DisconnectSessionsJob demonstrates a bounded retry for narrow network failures and idempotent disconnection.
- Diagnose through /ops/jobs, JSON logs and WorkerMetrics. queue.yml and ConcurrencyConfig define queues and pools.

Behavior sources: [app/jobs/application_job.rb](../../../../../app/jobs/application_job.rb), [app/jobs/disconnect_sessions_job.rb](../../../../../app/jobs/disconnect_sessions_job.rb), [docs/observability.md](../../../../../docs/observability.md), [test/models/session_test.rb](../../../../../test/models/session_test.rb).
