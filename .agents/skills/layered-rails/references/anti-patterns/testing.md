# Tests of internal mechanics

Symptom: A test duplicates implementation, checks private methods or mocks every domain interaction.

Correction: Specify observable behavior and failures. Use Minitest/fixtures, WebMock at HTTP boundaries, real database transactions and Cuprite for user journeys.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [docs/testing.md](../../../../../docs/testing.md), [docs/architecture.md](../../../../../docs/architecture.md).
