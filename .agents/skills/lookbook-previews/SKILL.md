---
name: lookbook-previews
description: Write or improve Lookbook previews for one real StarterApp ViewComponent or page, using actual call-site states, useful controls, shared factories, and rendering checks.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Previews — One Component, Its Real States

## Before Authoring

Read the component API/templates, actual callers, token usage, interaction controller,
existing previews/tests, and current inventory evidence. Determine whether this is a
primitive, composed component, page, or report. Choose material states from what the
component actually supports; don't invent props, mock products, or a Cartesian matrix.

Use the existing path `test/components/previews`. Keep one component's examples together.
Supported but unused variants may be documented, labelled as such, without pretending
they are shipped. Read [authoring.md](references/authoring.md) for factories, controls,
composition, state coverage, and the detailed authoring gate.

## Authoring Source

Use Ruby/ERB source and the installed ViewComponent/Lookbook APIs. Confirm preview
discovery and rendering in Lookbook.

```ruby
class Ui::NoticeComponentPreview < ViewComponent::Preview
  def notice
    render Ui::NoticeComponent.new(message: I18n.t("components.notice.saved", raise: true))
  end

  def alert
    render Ui::NoticeComponent.new(message: I18n.t("components.notice.invalid", raise: true), variant: :alert)
  end
end
```

This is the project's real existing pattern. For new examples, use translation keys and
real constructor inputs. Three or more cases sharing the same shape should use a small
explicit preview helper/factory; two straightforward cases don't require abstraction.

## Pages: Real Capture Versus Composition

Prefer the real view/component tree with deliberate preview inputs and context. If the
page cannot render outside a request, identify the exact dependency and provide a narrow
adapter or inspect the actual route in a browser. Don't build a static lookalike and call
it the real page. Mark a composed reference/mockup honestly if that is what was requested.

Use full-width page canvases, real responsive breakpoints, and meaningful loading/empty/
error/access states. Do not make a preview mutate production data or call a real external
service. Keep fixtures/factories deterministic and free of private content.

## Overlays

Open dialogs/sheets/popovers within an isolated preview document where needed. Prevent
their portal/scroll-lock behavior from capturing the catalog's own navigation. Test open,
close, Escape, focus return, and repeated preview switching. A forced CSS pseudo-class
is not proof of interactive behavior. Don't set a global full-height layout for every
small component merely to make one overlay render.

## Batch Work

Prioritize the verified needs-preview list and finish one component's source, states,
rendering, and meaningful checks before copying its pattern to the next. Reuse a common
shape where stable; don't generate dozens of placeholders or ask for another location
when the repository already established one.

## Gate Before Done

Verify Ruby/ERB syntax, framework discovery, actual rendering with project assets, valid
controls, material state coverage, and important interactions. Refresh usage evidence
when production call sites changed. A file passing syntax is not a rendered preview.
Keep production issues outside a documentation-only pass as recorded findings unless
the user requested fixes. Route comparisons to `lookbook-comparisons` and undecided
redesigns to `lookbook-explore`.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
