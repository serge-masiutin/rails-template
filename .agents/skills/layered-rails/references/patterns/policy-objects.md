# Authorization objects

- Inherit ApplicationPolicy with named predicates. Unknown rules raise; never default to allow.
- Call authorize! before disclosure/mutation. Collections need authorized_scope and scope verification.
- Hidden buttons do not authorize actions. Pass actors explicitly; Native User-Agent does not affect permissions.
- Test owner, another user, guest and unknown rules; collections need leak and N+1 checks.

Behavior sources: [app/policies/user_policy.rb](../../../../../app/policies/user_policy.rb), [test/policies/user_policy_test.rb](../../../../../test/policies/user_policy_test.rb), [test/controllers/authorization_test.rb](../../../../../test/controllers/authorization_test.rb).
