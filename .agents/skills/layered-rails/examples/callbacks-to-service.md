# Make side effects explicit

List callback actions and required atomicity first. Move related writes into a domain method such as User#reset_password; keep enqueue after commit as in Session.revoke_all!. Controllers delegate and database failures roll back the entire use case.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/models/user.rb](../../../../app/models/user.rb), [app/models/session.rb](../../../../app/models/session.rb), [test/integration/password_reset_atomicity_test.rb](../../../../test/integration/password_reset_atomicity_test.rb).
