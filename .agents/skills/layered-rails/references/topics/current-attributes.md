# Request and job context

- Current declares session and request_id. Execution context is thread-scoped; do not add hidden instance-variable memoization or shared class variables.
- Authentication sets Current.session; controllers set request_id. Policies receive the user at the HTTP boundary; pass domain dependencies explicitly.
- RequestCorrelatedJob carries request_id, adds job_id and clears HTTP session even for perform_now. Workers take user IDs and recheck access.
- Wrap application work in custom threads with Rails.application.executor.wrap and return database connections. Prefer existing workers over unmanaged threads.
- Use scoped Current.set in tests. Check simultaneous jobs, failures, restored outer context and absence of leakage into the next call.

Behavior sources: [app/models/current.rb](../../../../../app/models/current.rb), [app/jobs/concerns/request_correlated_job.rb](../../../../../app/jobs/concerns/request_correlated_job.rb), [test/lib/concurrency_test.rb](../../../../../test/lib/concurrency_test.rb), [test/jobs/request_correlated_job_test.rb](../../../../../test/jobs/request_correlated_job_test.rb).
