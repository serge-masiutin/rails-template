# Pass the actor explicitly

Find domain Current.user calls and every consumer. Controllers pass the actor after authorization; jobs reload by ID. Keep Current for HTTP/log context and RequestCorrelatedJob session cleanup. Test execution without HTTP and concurrent job isolation.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/models/current.rb](../../../../app/models/current.rb), [app/jobs/concerns/request_correlated_job.rb](../../../../app/jobs/concerns/request_correlated_job.rb), [test/lib/concurrency_test.rb](../../../../test/lib/concurrency_test.rb).
