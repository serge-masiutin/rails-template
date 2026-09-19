# Concerns without contracts

Symptom: A module combines unrelated validations, callbacks and HTTP dependencies just to shorten a file.

Correction: Extract one role with a required host API. Behavior with its own data belongs in a model-adjacent object; check every including host.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [app/jobs/concerns/request_correlated_job.rb](../../../../../app/jobs/concerns/request_correlated_job.rb), [docs/architecture.md](../../../../../docs/architecture.md).
