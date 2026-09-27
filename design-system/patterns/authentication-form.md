---
sourcesHash: a8337392f35ebfbf97173f1201d35c9ea7521e804f7f1d4bd8078d0676fc1191
id: authentication-form
description: >-
  Present sign-in or password recovery as one server-owned task with a heading,
  labelled credentials, actionable validation feedback, and one primary submit action.
status: discoverable
sources:
  - app/views/sessions/new.html.erb
  - app/views/passwords/new.html.erb
  - app/views/passwords/edit.html.erb
tests:
  - test/controllers/sessions_controller_test.rb
  - test/controllers/passwords_controller_test.rb
  - test/integration/localization_test.rb
  - test/system/authentication_test.rb
examples:
  - app/views/sessions/new.html.erb
  - app/views/passwords/edit.html.erb
---

# Authentication form

## When to use

- A person signs in with an email/password, requests password-reset instructions,
  or chooses a replacement password under the existing Rails authentication routes.
  Each page completes one of these tasks; it does not combine unrelated operations.

## When not to use

- The task edits general product data or administers another account. Its fields,
  access boundary, and action structure are outside this authentication recipe.

## Structure

Use [Application layout](../layouts/application.md). Inside its main region place
one centered `max-w-md` section with `space-y-6`: an H1, optional explanatory text,
optional [Notice](../components/notice.md) validation summary, one Rails form with
`space-y-5`, and any secondary help/navigation after the form.

The form contains [Fields](../components/field.md) in task order, then one
[Submit](../components/submit.md):

- Sign-in: email (`username` autocomplete, retained input, autofocus), then current
  password (`current-password`, maximum 72), then Sign in.
- Request reset: email (`username`), then Send reset instructions.
- Replace password: new password, confirmation (`new-password`, both 12–72), then
  Save password. Keep the signed token in the existing route and the PUT method.

Every credential is required. Labels and actions come from translations. This is
an ERB composition recipe, not a second form builder or a new backend API.

## Composition

The section owns its narrow width; the form owns spacing between complete fields.
Components own their internal appearance. Preserve Rails request names/IDs, form
URLs/methods, CSRF, server validation, and the existing return/error behavior.
No consumer should replace native submission with click handlers or move controls
outside their form. Browser constraints supplement server validation.

Sign-in keeps its existing disclosure button and help target outside the form,
with `type=button`, `aria-expanded`, and `aria-controls`. Reset request keeps the
back-to-sign-in link. A password-validation response preserves its summary and
associates each field's actual errors through `error`; passwords are never echoed.
Do not turn a bad-credentials message into a claim that one specific field is wrong.

## Verification

Run component checks, the session/password controller tests, localization tests,
and the authentication system test with the project's isolated test database.
See [testing](../../docs/testing.md) for commands and browser setup.

Check that the input names, token-bearing action, method override, autocomplete,
length constraints, labels, and error ID references survive composition. Reject a
form where a label references a missing ID, a submit control is outside the form,
or a password is rendered back in a value attribute. The browser journey must
still sign in, navigate through Turbo, sign out, and expand help. At a narrow width,
fields/actions remain inside the viewport and the shared navigation remains usable.
