# Hidden callback effects

Symptom: Network calls, email, publishing or cascading updates to other models inside save/destroy callbacks.

Correction: Move the use case into an explicit method/operation; group records in a transaction and enqueue after commit. Test rollback. Do not add skip flags or runtime skip_callback.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [app/models/user.rb](../../../../../app/models/user.rb), [docs/architecture.md](../../../../../docs/architecture.md).
