---
sourcesHash: a85984c0a5fd4f25292c72339fcea9cb70c7e42cc9bcf553bd2d8519cbe137cd
id: component-preview-layout
description: >-
  Render a real ViewComponent example in an isolated document with product tokens,
  typography, and Stimulus, so its supported states can be inspected without application navigation.
status: discoverable
sources:
  - app/views/layouts/component_preview.html.erb
  - app/views/shared/_typography.html.erb
  - app/assets/stylesheets/typography.css
  - app/assets/stylesheets/ui_tokens.css
  - app/assets/tailwind/application.css
  - config/application.rb
tests:
  - test/components/ui/field_component_test.rb
  - test/components/ui/submit_component_test.rb
examples:
  - test/components/previews/ui/field_component_preview.rb
  - test/components/previews/ui/field_component_preview/form.html.erb
  - test/components/previews/ui/submit_component_preview.rb
---

# Component preview layout

## When to use

- A Lookbook/ViewComponent example must show the actual component's supported state
  with the same shared assets as its product consumers, without product navigation
  or an authenticated page context.

## When not to use

- The result is an end-user page with navigation, access checks, and flash messages;
  use [Application layout](application.md) through the appropriate controller.
- The task changes the outer Lookbook interface rather than the example document;
  that surface uses the existing `layouts/lookbook/skeleton` gem integration.

## Public API

The project sets `config.view_component.previews.default_layout` to
`"component_preview"` in `config/application.rb`, shared by development and tests.
An explicit preview binding is also valid:

```ruby
class ExamplePreview < ViewComponent::Preview
  layout "component_preview"

  def saved
    render Ui::NoticeComponent.new(message: I18n.t("components.notice.saved"))
  end
end
```

The layout receives the example through `yield`; it owns the translated component
catalog title and document metadata. It provides no product-page slots, class
settings, or authentication context. Examples use the real component and stable
synthetic inputs rather than production records. Lookbook's mounted route remains
restricted to development by the project's route configuration.

## Composition

The layout owns the document, viewport, body padding, shared
[tokens](../../app/assets/stylesheets/ui_tokens.css), Tailwind, local typography,
and importmap. Examples own the immediate context their component needs: for
example, a scoped Rails form around [Field](../components/field.md) and
[Submit](../components/submit.md). Keep scoped input IDs unique when showing more
than one form or state in the same document.

The layout supplies neither product navigation nor flash nor a user subscription.
Examples must not depend on those omitted regions. Preview forms use synthetic
inputs and a preview-only action; inspecting or submitting a demonstration must not
mutate real application data or make paid/external calls. Loading the normal
Stimulus assets demonstrates component wiring but does not supply server behavior.

## Accessibility

The document sets the application's language/direction and loads its actual font
and focus-visible rules. Each example remains responsible for valid native parent
semantics, labels, feedback relationships, and unique IDs. This isolated document
has no main landmark or skip link. It therefore cannot establish full-page landmark
structure, heading hierarchy, or navigation/focus behavior in a product consumer;
verify those relationships on the actual page.
