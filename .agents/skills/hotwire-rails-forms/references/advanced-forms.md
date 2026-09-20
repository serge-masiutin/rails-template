# Advanced Form Patterns

## Programmatic Form Control

Prefer native elements first: `form` on an external button, `required`, `min`, `max`,
`pattern`, and an explicit submitter name/value. Use Stimulus when submission depends
on an interaction, not to maintain another copy of every input value.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitter"]

  submit() {
    this.formTarget.requestSubmit(this.submitterTarget)
  }
}
```

Targets are required by this example. Supply both in markup; do not silently skip the
operation with optional chaining if markup violates the controller's contract.
Choose a dedicated controller name and verify it is registered by the existing loader.

## Data Transforms

Normalize at the HTTP/form-object boundary, before validating domain input. Strip or
cast only documented inputs; don't “repair” missing required values with empty strings.
Use a hidden field for a derived UI value only when it is part of the explicit request
contract. Never trust client-calculated totals, ownership, roles, or prices.

If a submit button chooses an operation, use a named value and a server-side allowlist.
Do not let an arbitrary action string select Ruby methods through `send`.

```erb
<%= form.button t("posts.save_draft"), name: "intent", value: "draft" %>
<%= form.button t("posts.publish"), name: "intent", value: "publish" %>
```

Validate intent independently of the record attributes; authorize the chosen operation.
A submitter that is disabled or not supplied may be absent: make this part of the
request contract, with an explicit required/default intent at the boundary.

## Remember State and Dirty Forms

Turbo can restore a page snapshot; it is not a durable draft store. Decide whether
unsaved values should survive Back, refresh, navigation away, or a lost connection.
Use server-owned drafts for valuable long input. Persist only named safe fields if
session storage is justified; key by form/record/user and clear on completion/logout.
Never remember passwords, tokens, uploaded file contents, or sensitive trace text.

For a navigation guard, compare current entries with a snapshot captured after the
server values are rendered. Treat repeated-name arrays, unchecked booleans, and file
inputs deliberately. Suppress the guard for a successful submit, restore it on failure,
and remove global listeners on disconnect. Test Turbo visits and ordinary tab closing
separately; `beforeunload` is not a reliable background-save mechanism on mobile.

## Nested Data

Use `fields_for` for nested Active Record attributes only when the model deliberately
accepts them. The transport convention does not authorize nested IDs.

```erb
<%= form_with model: @project do |form| %>
  <%= form.fields_for :tasks do |task| %>
    <%= task.hidden_field :id if task.object.persisted? %>
    <%= task.label :title %>
    <%= task.text_field :title %>
    <%= task.check_box :_destroy %>
    <%= task.label :_destroy, t("tasks.remove") %>
  <% end %>
  <%= form.submit t("projects.save") %>
<% end %>
```

```ruby
params.expect(project: [:name, tasks_attributes: [[:id, :title, :_destroy]]])
```

Verify the installed Rails array/hash syntax against a request test for the exact
shape emitted by `fields_for`. Restrict nested records to the authorized parent, limit
count/size, and preserve nested error paths so messages identify the right row.
Use a form object when input combines several concepts or needs non-AR validation.

## Multiple Forms on One Page

Give each form unique element/error/frame IDs. Each submission owns its pending state
and errors. Do not disable every form on the page or put server errors in a shared
global store. Use separate endpoints or explicit operation parameters with individual
authorization. Re-render only the relevant form while preserving unrelated input.

If the page contains two editors for the same record, `dom_id(record)` alone is not
unique; use an explicit prefix such as `dom_id(record, :sidebar_edit)`.

## Conditional Submission

Use `data-turbo-confirm` for simple confirmation and native constraints for field
validity. For a richer dialog, prevent the first submit, retain the submitter, and
resubmit exactly once after confirmation. Prevent the confirmation handler from
reopening itself on the second submission. Cancel performs no request.
Server access/validation runs regardless of the confirmation result.

## Reset, Clear, and Defaults

| Action | Meaning | Implementation choice |
| --- | --- | --- |
| Cancel editing | Return to persisted values | Navigate to read view or reload authorized form |
| Reset fields | Restore markup defaults | Native `reset` and reset local presentation |
| Clear draft | Intentionally empty selected fields | Explicit input assignments, not blanket form reset |
| Clear local error | Remove a client validation message | `setCustomValidity("")`, update described message |
| Save and continue | New persisted baseline | Redirect/render fresh defaults and reset dirty snapshot |
| Save and add another | New empty record after success | Explicit server redirect to new form |

Don't reset user input on 422, network failure, or a broadcast that arrives while typing.
Do not use `form.reset()` as proof the database was saved.

## Dynamic Fields

Render an HTML `template` with a unique child-index placeholder for nested fields.
Clone it, replace the index in names/IDs/labels, and append real DOM nodes. Use a
monotonic per-form counter or collision-resistant index; array length can reuse IDs
after deletion. Avoid concatenating untrusted values into `innerHTML`.

For unsaved rows, remove the row. For persisted rows, set `_destroy` and hide the row
while retaining its ID and hidden input in the form. Move keyboard focus predictably
after add/remove. Re-render the same indexed rows on validation failure. Test adding,
deleting, re-adding, repeated names, nested errors, and deleting another user's ID.

## Multi-Step Forms

Model the workflow explicitly: valid steps, transitions, ownership, partial validity,
completion, and expiry. A URL step parameter is presentation input, not permission to
skip required steps. Persist a draft when refresh/resume/back navigation matters.
Authorize every step and final commit; revalidate the complete aggregate on completion.

For a short purely presentational wizard, keep one HTML form and reveal fieldsets with
Stimulus. Account for required hidden controls before `requestSubmit`. A long wizard
should submit each step to the server and redirect with 303. Do not send a giant draft
through hidden fields or trust client-supplied completed-step flags.

Test next/back, invalid earlier steps, expired draft, concurrent edit, double finish,
and access from a different account. Add idempotency only where the operation needs it;
the server must already protect its data invariants through transactions/constraints.

## Cache Invalidation

Identify the cache before invalidating:
Rails fragments/data, HTTP cache, Turbo snapshots, or component-local state.
Prefer record/version-based Rails cache keys. Use `Turbo.cache.clear()` only when a
mutation makes restoration snapshots unsafe; it does not invalidate Rails or HTTP.
Private operations UI follows `docs/observability.md`: invalidation events trigger an
authorized reload, coalesce updates, preserve input, stop in hidden tabs, and clear on
role loss. Never reset an active form simply because another record changed.

## Client-Side Validation

Use HTML constraints for immediate feedback and server validation for the contract.
Custom local messages come from Rails translations. Set and clear custom validity on
the relevant input; do not convert a server error into permanent client invalidity.
Use `reportValidity()` for an explicit interaction, not on every keystroke.

Remote validation is only a hint. Debounce/cancel an autocomplete or uniqueness check,
ignore stale responses, and enforce the same invariant atomically at final save.
Never leak another account's records through “available/taken” hints. Cover JS-disabled
or ordinary form submission where the product promises that baseline.
