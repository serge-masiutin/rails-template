# Extract an access rule

Replace repeated ownership checks with a named ApplicationPolicy rule. Call authorize! before disclosure; UserPolicy#show? is the existing example. Keep verify_authorized and test foreign records and guests.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/policies/user_policy.rb](../../../../app/policies/user_policy.rb), [app/controllers/accounts_controller.rb](../../../../app/controllers/accounts_controller.rb), [test/controllers/authorization_test.rb](../../../../test/controllers/authorization_test.rb).
