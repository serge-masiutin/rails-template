---
sourcesHash: 416449e32f6172a769035bb6c95ba08f47511b0b6351dd81712f17d5786919dc
id: mission-control-layout
description: >-
  Frame Mission Control's queue-management pages with the starter's administration
  navigation and live updates while preserving the engine's forms, assets, and access boundaries.
status: discoverable
sources:
  - app/views/layouts/mission_control/jobs/application.html.erb
  - app/views/shared/_typography.html.erb
  - app/views/admin/_navigation.html.erb
  - app/views/admin/shared/_stream.html.erb
  - app/views/admin/shared/_live_status.html.erb
  - app/assets/stylesheets/typography.css
  - app/assets/stylesheets/ui_tokens.css
  - app/assets/stylesheets/admin_navigation.css
  - app/javascript/admin_jobs.js
tests:
  - test/integration/admin_test.rb
  - test/system/admin_test.rb
examples:
  - app/views/layouts/mission_control/jobs/application.html.erb
---

# Mission Control layout

## When to use

- An authorized administrator manages background jobs through the installed
  `mission_control-jobs` engine and needs the shared administration navigation
  around its pages.

## When not to use

- A custom Rails administration page does not use the engine's controller/helpers;
  use [Admin layout](admin.md) without its Mission Control dependencies.
- An ordinary end user needs a product-facing job/status view; this shell neither
  grants engine access nor supplies a public queue-viewing API.

## Public API

The binding is the Rails override `layouts/mission_control/jobs/application` for
Mission Control. The engine supplies `page_title`, `selectable_applications`,
`@application`, its application-selection/flash/navigation partials, and yielded
page content. Do not render this shell from an unrelated controller that lacks
that context. The existing engine integration and `Admin::BaseController` own
access checks, CSRF, and job actions; the layout does not replace them.

The shell has no public class or theme parameters. Its title combines Mission
Control with the engine's `page_title`; its live-status text comes from application
translations. See the actual
[override](../../app/views/layouts/mission_control/jobs/application.html.erb) when
upgrading the pinned engine, because its expected helpers and partials are
version-specific.

## Composition

Required order is shared administration navigation, shared operations subscription,
then `.section.admin-main`: an H1 with live status, followed by
`turbo-frame#jobs-content`. The frame contains the engine's application selector
when required, engine flash, engine navigation, and the yielded page in that order.
The frame targets `_top` for navigation. Preserve its ID and the live-region target
relationships; do not replace it with a second independent refresh system.

The layout keeps the engine's Bulma/CSS/importmap and loads `admin_jobs` to register
the existing live-region controller and operations-stream integration. It loads
[shared tokens](../../app/assets/stylesheets/ui_tokens.css), typography, and
[navigation styles](../../app/assets/stylesheets/admin_navigation.css) without the
product Tailwind reset. The shell owns the sidebar offset and narrow-screen
adaptation; the engine owns its inner tables, controls, and layout.

The engine section retains `lang="en"` because its strings belong to the engine;
the surrounding document uses the application locale/direction. Turbo cache and
prefetch are disabled for this integration. Cross-tool navigation uses full page
loads. The existing live-region controller preserves active filter editing and
reports its paused state; layout work must preserve that behavior.

## Accessibility

The shared navigation has an accessible name and current-destination indication.
Mission Control has an H1 and a textual status, so connectivity is not conveyed
only by a colored dot. The engine owns labels and table semantics inside the frame.
The current override uses `section`, not `main`, and provides no skip link; it does
not promise the main/skip-link facilities of Application or Admin layout.
Navigation focus styles come from shared CSS. Preserve engine keyboard behavior
and the tested filter-editing state rather than changing them through shell styles.
