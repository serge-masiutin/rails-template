# Authorization

- Call authorize! before private reads or mutations. Keep ApplicationController verify_authorized and named ApplicationPolicy rules.
- Collections need authorized_scope and scope verification; authorizing one record does not filter others.
- Pass actor/owner to the domain explicitly. Hidden buttons and Native User-Agent never grant permission.
- Jobs reload user and record and authorize at execution time; HTTP Current.user is not inherited.
- Sessions/passwords have separate tested password/token boundaries. Admin, Mission Control and AgentPrism check session/AdminPolicy on every request. Health uses OperationsConfig Basic credentials; metrics uses separate Bearer credentials.
- Test guest, owner, foreign record, session revocation and unknown rules. default_rule nil preserves a loud failure for unknown policy API.

Behavior sources: [app/policies/application_policy.rb](../../../../../app/policies/application_policy.rb), [app/policies/user_policy.rb](../../../../../app/policies/user_policy.rb), [test/controllers/authorization_test.rb](../../../../../test/controllers/authorization_test.rb), [test/policies/user_policy_test.rb](../../../../../test/policies/user_policy_test.rb).
