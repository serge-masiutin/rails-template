# Tests as contract specifications

- Specify input, output, effects, errors, permissions and data ownership. For jobs, include commit/rollback, repeat execution and context.
- Model tests cover invariants; HTTP tests cover access, parameters, status and HTML/JSON; component tests cover semantics; Cuprite covers browser behavior.
- Use current Minitest 6, fixtures, WebMock and Cuprite APIs. Do not assume Object#stub is built into this Minitest version.
- Test observable behavior, not private method sequences or a fully mocked implementation.
- AI needs both transport tests and quality evals; a successful HTTP stub says nothing about generated answer quality.
- Start narrow, expand to the affected scenario and CI, and report untested platforms.

Behavior sources: [docs/testing.md](../../../../../docs/testing.md), [test/integration/password_reset_atomicity_test.rb](../../../../../test/integration/password_reset_atomicity_test.rb), [test/agents/application_agent_test.rb](../../../../../test/agents/application_agent_test.rb).
