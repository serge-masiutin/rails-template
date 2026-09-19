# Callbacks and transactions

- Use callbacks for local record invariants. Keep HTTP, delivery, publishing and multi-step use cases explicit.
- Trace save/destroy/callback conditions, order, transaction and rollback before editing; the callback name alone is not evidence of a problem.
- Group related database writes in one transaction. User#reset_password and Session.revoke_all! ensure session-revocation failure cannot leave a new password with old sessions.
- ApplicationJob, MailDeliveryJob and NotifierDeliveryJob enqueue after commit. Other local callbacks use AfterCommitEverywhere.after_commit(without_tx: :raise) inside an explicit transaction.
- After-commit callbacks alone cannot guarantee delivery across a process crash. Use jobs for reliable actions; atomicity across primary/queue databases needs a separately designed outbox.
- Do not mutate global callbacks or disable Isolator to bypass a failure. Test success, rollback and boundary failure.

Behavior sources: [app/models/user.rb](../../../../../app/models/user.rb), [app/models/session.rb](../../../../../app/models/session.rb), [test/lib/transaction_safety_test.rb](../../../../../test/lib/transaction_safety_test.rb), [test/integration/password_reset_atomicity_test.rb](../../../../../test/integration/password_reset_atomicity_test.rb).
