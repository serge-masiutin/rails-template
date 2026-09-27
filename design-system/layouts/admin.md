---
sourcesHash: 35a54f67210961469df7ea09e3de0fcfed8a5d4b22222757f2357ae1218df9a9
id: admin-layout
description: >-
  Arrange server-rendered administration pages alongside shared operations
  navigation, preserving access boundaries and adapting the sidebar on narrow screens.
status: discoverable
sources:
  - app/views/layouts/admin.html.erb
  - app/views/admin/_navigation.html.erb
  - app/views/admin/shared/_stream.html.erb
  - app/views/shared/_typography.html.erb
  - app/assets/stylesheets/admin_navigation.css
  - app/assets/stylesheets/ui_tokens.css
  - app/assets/tailwind/application.css
tests:
  - test/integration/admin_test.rb
  - test/system/admin_test.rb
examples:
  - app/views/admin/dashboard/show.html.erb
  - app/views/admin/observability/show.html.erb
---

# Admin layout

## When to use

- An authorized administrator views a server-rendered operations page with the
  shared Overview, Mission Control, AgentPrism, and Monitoring destinations.

## When not to use

- The page is ordinary user-facing product content; use [Application layout](application.md).
- The content is the AgentPrism JavaScript viewer; [Operations layout](operations.md)
  loads its bundle and places its root without a second main region.
- The content belongs to Mission Control's engine: retain its existing
  `layouts/mission_control/jobs/application` integration, which owns the engine's
  assets and turbo frame while reusing these navigation styles and tokens.

## Public API

Use the existing `Admin::BaseController` layout selection, authorization, and helpers.
A page supplies translated `content_for :title` and its body. The layout loads
Tailwind, [navigation styles](../../app/assets/stylesheets/admin_navigation.css),
[shared tokens](../../app/assets/stylesheets/ui_tokens.css), typography, and the
operations stream module. It is not a public override for bypassing admin access.

## Composition

Required order is skip link, shared navigation, shared subscription, then
`main#main.admin-main` containing page content. The layout owns outer spacing and
navigation offset; page content owns headings, sections, and any live-region targets.
Preserve the shared stream ID and existing live-region controller relationships.

Above 900px the sidebar is fixed at 224px and content is offset; at 900px or below
navigation returns to normal flow and its links can scroll horizontally. Pages must
not copy or compensate for that offset. Current destinations retain `aria-current`.
Development links remain development-only. Navigation intentionally disables Turbo
when crossing operations surfaces; preserve that compatibility boundary.

## Accessibility

The layout supplies the skip link and labelled administration navigation. Page
content supplies an H1 and text for live status, so the status dot is not the only
signal. A page must not add a nested main or duplicate navigation landmarks.
CSS governs focus-visible treatment and narrow-screen placement; access is always
checked server-side regardless of browser or Native presentation.
