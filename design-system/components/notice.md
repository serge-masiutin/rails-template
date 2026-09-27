---
sourcesHash: 8023c492abee0694e81b527fda61fd3d6f4681cc44961554a649f0fb236c52ed
id: notice
description: >-
  Announce a form-wide or page-wide result or problem as escaped inline text,
  distinguishing normal status updates from errors requiring attention.
status: discoverable
sources:
  - app/components/ui/notice_component.rb
  - app/components/ui/notice_component.html.erb
  - app/assets/tailwind/application.css
  - app/assets/stylesheets/ui_tokens.css
tests:
  - test/components/ui/notice_component_test.rb
examples:
  - test/components/previews/ui/notice_component_preview.rb
---

# Notice

## When to use

- Feedback applies to an operation or composition as a whole, such as successful
  password change or a sign-in failure, and should remain readable in the page.
- A validation summary must precede the form; retain field-specific associations
  through [Field](field.md) where individual inputs are invalid.

## When not to use

- Text simply explains an input; use the field's `hint` instead of announcing it.
- A marker describes an item's persistent status rather than a new operation
  result; use ordinary status text in that item's composition.

## Public API

```erb
<%= render Ui::NoticeComponent.new(message: t("auth.password_changed")) %>
```

Required `message` is escaped plain text. `variant: :notice` is the default for
normal status; choose `:alert` for a problem requiring attention. Unknown variants
raise `KeyError`. The two variants select the border/background treatment and
`status`/`alert` role; there are no slots, HTML content, dismissal, or class overrides.
The component owns internal padding/radius/colors through
[Tailwind tokens](../../app/assets/tailwind/application.css); the parent owns width,
placement, and spacing between notices.

## Behaviour and states

The message renders immediately and stays present until its parent removes it.
The application flash region is Turbo-temporary and controls flash lifetime;
Notice itself has no timer, state, focus change, or event handler.

## Accessibility

Normal updates use `role=status`; errors use `role=alert`. Do not nest another live
region or announce the same message through a second notification channel. Consumers
supply meaningful translated text and keep actionable remediation available in the
surrounding composition. The notice itself is not a form control or focus target.
