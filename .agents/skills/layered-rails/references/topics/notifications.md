# Application notifications

- Enter through an ApplicationDelivery subclass that declares delivers and chooses mailer/notifier handlers. Invoke delivery explicitly from the operation.
- Mailers own email; notifiers own channel payloads. Abstract Notifier is included in active_delivery; no separate dependency is needed.
- Non-email channels need a driver with call(payload). Missing transport must raise, not become noop. Push/SMS are not configured yet.
- deliver_later uses the configured queue after commit. Pass minimal arguments: Solid Queue persists them even when logging excludes them.
- Test enqueue, recipient, payload, rollback, request_id and delivery failures. Retrying requires explicit idempotency.
- Actual SMTP delivery needs a configured server; a test adapter does not prove mailbox delivery.

Behavior sources: [app/deliveries/passwords_delivery.rb](../../../../../app/deliveries/passwords_delivery.rb), [app/notifiers/application_notifier.rb](../../../../../app/notifiers/application_notifier.rb), [test/jobs/notifier_delivery_job_test.rb](../../../../../test/jobs/notifier_delivery_job_test.rb), [docs/deployment.md](../../../../../docs/deployment.md).
