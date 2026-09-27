---
sourcesHash: fb7ff4b7138025da0b6077d576a31bfbefe8f192baca07bfeba507efacb11e21
id: field
description: >-
  Collect one email address or password through a Rails form builder, keeping its
  visible label, native input constraints, hints, and validation errors associated.
status: discoverable
sources:
  - app/components/ui/field_component.rb
  - app/components/ui/field_component.html.erb
  - app/assets/tailwind/application.css
  - app/assets/stylesheets/ui_tokens.css
tests:
  - test/components/ui/field_component_test.rb
examples:
  - test/components/previews/ui/field_component_preview.rb
  - test/components/previews/ui/field_component_preview/form.html.erb
---

# Field

## When to use

- The person supplies an email address or password as one successful control in a
  server-owned Rails form. The component keeps the label and feedback tied to that
  field; the form owns submission and validation.
- A validation message belongs to one supported field rather than the whole form;
  pass it as `error` so returning focus to the input exposes that relationship.
  Use a [Notice](notice.md) for form-wide feedback instead.

## When not to use

- The input is a textarea, selection, checkbox, upload, or general text value; those
  have different native controls and are outside this component's supported types.
- The content is read-only information; use ordinary text instead of an input.

## Public API

```erb
<%= form_with url: session_path do |form| %>
  <%= render Ui::FieldComponent.new(form: form, attribute: :email_address,
        label: t("fields.email"), type: :email, required: true,
        autocomplete: "username", value: params[:email_address]) %>
<% end %>
```

- Required `form` is the active Rails builder; `attribute` names its submitted field.
  The builder generates both the request name and DOM ID, including a supplied form
  scope. Use distinct scopes when multiple forms with matching attributes coexist.
- Required `label` is translated visible text; `type` is `:email` for an address or
  `:password` for a secret. Unsupported types raise rather than silently changing
  the input contract.
- `required: false` uses optional native input by default; set true when the server
  requires that field. `autofocus: false` can become true for at most one intentional
  initial focus target in a composition.
- `autocomplete: nil` leaves browser completion unspecified. Use `username` for
  sign-in/reset identity, `current-password` for sign-in, and `new-password` for
  creating the replacement password; match the task rather than the field label.
- `value: nil` supplies an email's initial/retained text only. Password values are
  never echoed by this API. A bound builder otherwise retains Rails behavior.
- `minlength: nil` and `maxlength: nil` impose no component limit. Set them from the
  server's length contract; authentication currently uses a maximum of 72 and
  replacement passwords a minimum of 12 characters.
- `hint: nil` and `error: nil` omit feedback. A nonempty `error` is the server's
  field-specific message; an empty error string also means no error, allowing
  `errors.full_messages_for(attribute).to_sentence`. `hint` supplies supplementary
  instructions. These inputs are escaped text, never HTML.

The component owns input/label/feedback classes and internal spacing, using the
[shared color definitions](../../app/assets/stylesheets/ui_tokens.css).
The surrounding form owns field order, width, and spacing between fields. There is
no arbitrary class override, event handler, disabled-field API, or custom ID override.

## Behaviour and states

It renders an email or password control using the builder, preserving native
required/length/autocomplete behavior. A field error adds `aria-invalid="true"`
and describes the input with the error paragraph; hints and errors can coexist.
No client validation, submission, focus movement, or live announcement is added.
Changing the message is the server/form consumer's responsibility.

## Accessibility

The label's `for` matches the builder-generated input ID. Feedback IDs derive from
that same ID, and `aria-describedby` names only present feedback. The consumer
supplies meaningful translated text and unique scopes, preserves server validation,
and decides the one autofocus target. The shared focus-visible rule applies.
