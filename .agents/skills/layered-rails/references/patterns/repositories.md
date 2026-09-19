# Storage boundaries

- Active Record already provides a storage interface. Do not wrap find/save in a repository with no additional contract.
- Use scopes/query objects for read composition. A separate repository is justified when the domain needs its own objects from another store or several sources.
- Specify inputs, result type, missing records, errors, transactions and ownership. Queries must not execute commands.
- Test the actual storage adapter at its boundary; mocking every query does not validate SQL or data integrity.

Behavior sources: [docs/architecture.md](../../../../../docs/architecture.md), [app/models/application_record.rb](../../../../../app/models/application_record.rb), [test/integration/password_reset_atomicity_test.rb](../../../../../test/integration/password_reset_atomicity_test.rb).
