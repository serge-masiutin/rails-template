# Incorrect job boundaries

Symptom: A job contains domain rules, depends on Current.user, takes secrets as arguments or hides failures.

Correction: Keep an explicit thin ApplicationJob with IDs and an error policy. Short delegation is useful: the job owns queue, commit, log context and retries. Do not replace it with generated model methods.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [app/jobs/disconnect_sessions_job.rb](../../../../../app/jobs/disconnect_sessions_job.rb), [docs/architecture.md](../../../../../docs/architecture.md).
