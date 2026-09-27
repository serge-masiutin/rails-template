---
sourcesHash: f3081b1265cde2113dc4f8dcb1e80fd8e4c9faa00dadab5a82b58921cd93f9b3
id: submit
description: >-
  Submit a Rails form through its full-width primary action, preserving native
  submit-control semantics and optional unavailable or Turbo submitting states.
status: discoverable
sources:
  - app/components/ui/submit_component.rb
  - app/components/ui/submit_component.html.erb
  - app/assets/tailwind/application.css
  - app/assets/stylesheets/ui_tokens.css
tests:
  - test/components/ui/submit_component_test.rb
examples:
  - test/components/previews/ui/submit_component_preview.rb
  - test/components/previews/ui/submit_component_preview/form.html.erb
---

# Submit

## When to use

- The person completes the current form through its primary action, in a vertical
  form where that action occupies the form width. The form determines the endpoint
  and HTTP method; this component supplies the submit control.

## When not to use

- The action navigates to another page; use a Rails link with a real destination.
- The action only opens/closes local UI; use a native `button type="button"` and
  the existing Stimulus controller rather than submitting the form.
- Several sibling actions require differing emphasis or compact toolbar placement;
  this component intentionally has one full-width primary presentation.

## Public API

```erb
<%= form_with url: passwords_path do |form| %>
  <%= render Ui::SubmitComponent.new(form: form, label: t("actions.send_reset")) %>
<% end %>
```

Required `form` is the containing Rails builder and required `label` is translated
text naming the form's resulting action. `disabled: false` is suitable for an
available action; true represents an explicitly unavailable submission and emits
native `disabled`. Do not disable merely to hide a validation error.
`submitting_label: nil` leaves the current label during submission; supply translated
progress text when the consumer needs Turbo's `data-turbo-submits-with` behavior.
Turbo owns the temporary label and disabled state while a request is pending.

The implementation remains Rails `form.submit`, producing `input[type=submit]`
with `name=commit`. No route, method, validation, callback, arbitrary class, size,
or variant API is added. The component owns its full-width accent presentation;
the form owns surrounding spacing. Colors come from the
[shared definitions](../../app/assets/stylesheets/ui_tokens.css).

## Behaviour and states

An enabled control invokes ordinary browser/Rails/Turbo form submission. The disabled
state is unavailable to activation and keyboard focus. The component does not alter
server validation or dispatch requests itself. The disabled preview documents a
supported state; the current authentication consumers leave submission enabled.

## Accessibility

The visible label is the native control's accessible name. Preserve the input's
native keyboard behavior and focus-visible outline; consumers must not simulate
links or local toggles through this submit component. Explain why an action is
unavailable in surrounding text when that reason is not otherwise apparent.
