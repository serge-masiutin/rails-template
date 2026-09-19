# Transitions and concurrency

- Map state → event → next state with preconditions/effects; do not invent states absent from the use case.
- A named domain method changes state with a transaction and appropriate lock/conditional SQL. A Ruby Mutex cannot protect multiple processes.
- Define invalid-transition and repeated-command outcomes. Enum and limits_concurrency do not create idempotency.
- Publish/deliver after commit, separately from database mutation. Test each failure boundary.
- Session revocation uses record deletion and DisconnectSessionsJob, not an artificial enum. Add complexity only for a new contract.

Behavior sources: [app/models/session.rb](../../../../../app/models/session.rb), [app/jobs/disconnect_sessions_job.rb](../../../../../app/jobs/disconnect_sessions_job.rb), [test/models/session_test.rb](../../../../../test/models/session_test.rb), [docs/architecture.md](../../../../../docs/architecture.md).
