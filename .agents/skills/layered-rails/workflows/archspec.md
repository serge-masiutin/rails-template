# Test architectural rules

1. Identify a recurring violation and express an observable invariant.
2. Reuse an existing test, RuboCop or Zeitwerk check when suitable. Do not restate directory structure in another configuration.
3. New automation must catch a real regression without imposing empty layers on simple Rails code.
4. Integrate it into bin/ci or the existing workflow and document the verified command.

Show reproducible failure before and success after the fix. This project currently needs no separate architectural gem.

Behavior sources: [.rubocop.yml](../../../../.rubocop.yml), [config/ci.rb](../../../../config/ci.rb), [docs/testing.md](../../../../docs/testing.md).
