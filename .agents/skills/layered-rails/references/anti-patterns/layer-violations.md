# Incorrect dependency direction

Symptom: A model reads params/cookies/Current.user, a serializer runs a command, or a component fetches network data.

Correction: Inspect the actual caller. Pass actor and validated values explicitly, separate commands from queries, move IO to its declared boundary and test HTTP/job journeys.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [app/controllers/accounts_controller.rb](../../../../../app/controllers/accounts_controller.rb), [docs/architecture.md](../../../../../docs/architecture.md).
