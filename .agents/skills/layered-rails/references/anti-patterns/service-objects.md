# Empty or overly general operations

Symptom: A wrapper only renames Model.find, or a generic manager hides unrelated actions and results.

Correction: Keep the simple Rails call or extract one domain use case next to its model. Do not remove model invariants to impose an anemic architecture.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [app/models/user.rb](../../../../../app/models/user.rb), [docs/architecture.md](../../../../../docs/architecture.md).
