# Forms spanning multiple records

- Keep one-model forms conventional with form_with and model validations. Extract a form object for multiple records or an independent input contract.
- Use ActiveModel, explicit attributes/errors and a public save/submit. Keep requests, cookies and HTTP response handling outside.
- params.expect and authorization stay at the controller boundary; models own domain invariants.
- Use one transaction for atomic writes and jobs after commit for external effects.
- Re-render values/errors with 422; redirect with 303 on success. Preserve frame IDs and Android modal behavior.
- Test partial failure, rollback, malformed input and the user journey.

Behavior sources: [docs/hotwire.md](../../../../../docs/hotwire.md), [app/views/passwords/edit.html.erb](../../../../../app/views/passwords/edit.html.erb), [test/controllers/passwords_controller_test.rb](../../../../../test/controllers/passwords_controller_test.rb).
