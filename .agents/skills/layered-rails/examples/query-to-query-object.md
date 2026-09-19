# Extract a complex query

Preserve authorized scope, parameters and result type. Keep simple where/order/limit chains local; extract repeated composition into an explicit query. Operations::QueueSnapshot demonstrates an aggregate contract. Test correctness, N+1 behavior and consistent web/worker reads.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/models/operations/queue_snapshot.rb](../../../../app/models/operations/queue_snapshot.rb), [test/models/queue_snapshot_test.rb](../../../../test/models/queue_snapshot_test.rb).
