# Make state transitions explicit

Find scattered status checks and define an allowed event/precondition. Check/write atomically and define repeated-call and external-effect behavior. Session already expresses revocation through revoke!; it needs no additional enum/workflow gem. Test races and rollback.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/models/session.rb](../../../../app/models/session.rb), [test/models/session_test.rb](../../../../test/models/session_test.rb), [test/lib/concurrency_test.rb](../../../../test/lib/concurrency_test.rb).
