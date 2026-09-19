# Cohesive Rails concerns

- A concern supplies one complete capability with a clear host contract; do not split modules merely by file size.
- Declare required methods, callbacks and effects explicitly. Never mutate included callbacks during requests.
- Authentication owns HTTP-session lifecycle; RequestCorrelatedJob transfers and clears job context. Keep those roles separate.
- Test a real host through success and failure. Context tests cover sequential and concurrent calls without state leakage.

Behavior sources: [app/controllers/concerns/authentication.rb](../../../../../app/controllers/concerns/authentication.rb), [app/jobs/concerns/request_correlated_job.rb](../../../../../app/jobs/concerns/request_correlated_job.rb), [test/jobs/request_correlated_job_test.rb](../../../../../test/jobs/request_correlated_job_test.rb).
