# Explicit state transitions

- Describe actual states, events, transitions and invariants first. Do not add a state machine when one atomic operation suffices.
- Expose transitions through domain methods, not arbitrary status assignment from params. Use an enum/type and database constraints for stable state.
- Check and mutate in one transaction with locking or atomic conditional SQL when concurrent callers exist.
- Move network effects outside the transaction into an explicit job after commit.
- Test invalid transitions, repeats, races and rollback. Add a workflow gem only for an established need.

Behavior sources: [app/models/session.rb](../../../../../app/models/session.rb), [app/models/user.rb](../../../../../app/models/user.rb), [test/lib/concurrency_test.rb](../../../../../test/lib/concurrency_test.rb), [docs/architecture.md](../../../../../docs/architecture.md).
