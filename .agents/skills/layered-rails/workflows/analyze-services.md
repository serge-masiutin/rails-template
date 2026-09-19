# Review operations and wrappers

1. Find actual operations in models/namespaces, controllers and jobs. Do not assume app/services or a shared base class exists.
2. Define each candidate's use case, input, result, errors, transaction and external effects.
3. Distinguish domain behavior, queries, forms, policies, components and infrastructure adapters. Renaming alone does not change architecture.
4. Trace empty wrappers, hidden Current/request dependencies, duplicated rules and incompatible results through real execution paths.
5. Keep simple CRUD local and invariants in models; extract operations for stable responsibility.
6. Check public behavior with Minitest, HTTP boundaries with WebMock and real commit/rollback. Do not remove a useful test solely because it resides in another layer.

Report confirmed problems, consumer paths, local corrections and checks. Do not generate unnecessary base classes, DSLs, long HTML reports or dependencies.

Behavior sources: [docs/architecture.md](../../../../docs/architecture.md), [app/models/user.rb](../../../../app/models/user.rb), [app/models/agent_trace/capture.rb](../../../../app/models/agent_trace/capture.rb), [test/integration/password_reset_atomicity_test.rb](../../../../test/integration/password_reset_atomicity_test.rb).
