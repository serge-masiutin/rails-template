# Active Delivery contract

API: [palkan/active_delivery](https://github.com/palkan/active_delivery); version: Gemfile.lock.
Abstract Notifier is included in this gem.

- Inherit ApplicationDelivery; mailer and notifier lines are configured. Declare events with `delivers`; `deliver_actions_required = true` rejects implicit events.

```ruby
class PasswordsDelivery < ApplicationDelivery
  mailer "PasswordsMailer"
  delivers :reset
end

PasswordsDelivery.reset(user).deliver_later
```

- Specify handler names as strings for Rails reloading.
- For an additional channel, register `register_line :push, ActiveDelivery::Lines::Notifier`, then select an actual notifier with `push "PushNotifier"` in the concrete delivery.
- Every selected handler must accept the event and its arguments. Do not use `deliver_by`; the installed version has no such API.
- Inherit ApplicationNotifier and set `self.driver` to an object with `call(payload)`. Events return `notification(body: ..., ...)`. Push/SMS providers are not configured yet.
- MailDeliveryJob/NotifierDeliveryJob run after commit with request correlation; do not send synchronously inside a transaction.
- Check email enqueue with `assert_enqueued_email_with PasswordsMailer, :reset, args: [user]`.
- Check payload, driver selection, rollback and request_id. AbstractNotifier `:test` mode intercepts before Active Job; use `:normal` plus a test driver when testing real enqueue and restore the mode in teardown. See `test/jobs/notifier_delivery_job_test.rb`.
- Never use `:noop` to mask a missing transport. Delivery failures must remain visible in the queue.
