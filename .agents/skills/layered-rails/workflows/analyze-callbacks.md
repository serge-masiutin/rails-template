# Review callbacks

1. Trace callbacks, conditions and nested save/destroy, delivery and HTTP calls.
2. Identify record invariants and the atomic use case. Retain necessary normalization and make network effects explicit.
3. Check commit, rollback, database failure and enqueue timing. Account for separate primary/queue databases and the post-commit gap.
4. Do not globally change callbacks or disable Isolator. Extract only a demonstrated misplaced responsibility.

Report the actual call chain and verified resulting contract, without arbitrary quality scores.

Behavior sources: [app/models/user.rb](../../../../app/models/user.rb), [test/integration/password_reset_atomicity_test.rb](../../../../test/integration/password_reset_atomicity_test.rb), [test/lib/transaction_safety_test.rb](../../../../test/lib/transaction_safety_test.rb).
