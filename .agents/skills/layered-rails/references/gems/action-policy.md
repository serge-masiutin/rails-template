# Action Policy contract

API: [palkan/action_policy](https://github.com/palkan/action_policy); version: Gemfile.lock.
Read ApplicationController, ApplicationPolicy and UserPolicy.

- Policy context is `user`, supplied from Current.user at the controller boundary.
- Before private reads/mutations call `authorize! record, to: :rule_name?`; conventional actions infer the rule from the action name.
- `verify_authorized` detects missing checks. Inherit ApplicationPolicy; unknown rules raise. Do not add a blanket admin/default permission without a domain requirement.
- ActionPolicy::Unauthorized produces 403. Missing authorization is an implementation failure, not an ordinary denial to hide with rescue.
- Filter collections through `authorized_scope` and policy `relation_scope`; add `verify_authorized_scoped`. Authorizing an action alone does not filter rows.
- Exceptions require a separately tested boundary: password/signed-token session flows, Basic health or Bearer metrics. Panels require AdminPolicy#access?. New public actions need explicit decisions and tests.
- Native User-Agent never grants access; web and Android share cookies, CSRF and policies.
- Test owner, another user, guest, unknown rule, omitted authorization and exclusion of foreign rows. See `test/policies/user_policy_test.rb`, `test/controllers/authorization_test.rb` and `test/integration/navigation_test.rb`.
