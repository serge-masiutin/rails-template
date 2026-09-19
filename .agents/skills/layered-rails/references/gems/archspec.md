# Checking architectural boundaries

- Actual calls, schemas and docs/architecture.md define architecture. Do not add a dependency to restate directory structure.
- Zeitwerk checks loading; RuboCop checks style/thread safety; Minitest checks access, transactions, contracts and effects.
- For recurring violations, first add a minimal public-contract regression check. A custom cop needs a stable unambiguous rule.
- Architecture tests must not forbid valid simple CRUD or require empty services/repositories.
- Report the call path, violated invariant, consequence and verifiable correction.

Behavior sources: [docs/architecture.md](../../../../../docs/architecture.md), [config/ci.rb](../../../../../config/ci.rb), [.rubocop.yml](../../../../../.rubocop.yml), [test/lib/transaction_safety_test.rb](../../../../../test/lib/transaction_safety_test.rb).
