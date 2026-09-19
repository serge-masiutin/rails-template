# Collection filters

- Parse external input once; filters receive validated values and an authorized scope.
- An absent optional filter differs from an invalid one. Malformed input must not return the whole dataset.
- Allowlist sort columns, parameterize SQL values, bound page size and make ordering deterministic.
- Return a relation while further conditions may be added; avoid premature to_a.
- Test filter combinations, cursors, boundary sizes and inaccessible records.

Behavior sources: [app/controllers/operations/agents_controller.rb](../../../../../app/controllers/operations/agents_controller.rb), [test/controllers/operations/agents_controller_test.rb](../../../../../test/controllers/operations/agents_controller_test.rb).
