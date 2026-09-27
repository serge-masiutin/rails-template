---
sourcesHash: dadf5ff1285ea26677ccc88615d41a1d6a8b46edf41669b29c8a9d8456ef2646
id: operations-layout
description: >-
  Host the administrator's AgentPrism trace viewer with its isolated bundle,
  shared administration navigation, and operations subscription.
status: discoverable
sources:
  - app/views/layouts/operations.html.erb
  - app/views/admin/_navigation.html.erb
  - app/views/admin/shared/_stream.html.erb
  - app/views/operations/agents/index.html.erb
  - app/assets/stylesheets/admin_navigation.css
  - app/assets/stylesheets/ui_tokens.css
  - app/views/shared/_typography.html.erb
tests:
  - test/integration/admin_test.rb
  - test/system/agent_prism_test.rb
examples:
  - app/views/operations/agents/index.html.erb
---

# Operations layout

## When to use

- An authorized administrator inspects agent traces using the existing AgentPrism
  viewer; the page requires that viewer's JavaScript/CSS bundle and JSON boundary.

## When not to use

- A server-rendered administration page does not host the viewer; use
  [Admin layout](admin.md) to get its normal main region and Tailwind assets.
- A product page serves ordinary users; use [Application layout](application.md).

## Public API

The existing operations controller selects `layout "operations"`. It yields the
real `operations/agents/index` view: `main#agent-prism` with its data URL and translated
message dictionary, plus the noscript message. The viewer API, fetching, and state
remain owned by the project's AgentPrism integration, not by design-system code.
The layout has no slot or class override API and does not load the product Tailwind
bundle. It explicitly loads [shared tokens](../../app/assets/stylesheets/ui_tokens.css)
and [navigation CSS](../../app/assets/stylesheets/admin_navigation.css) alongside
AgentPrism assets and typography.

## Composition

Preserve the navigation, shared subscription, and yielded viewer root in that order.
The `.admin-shell--agents` shell owns the sidebar offset and its removal at 900px;
the viewer owns its internal panels. The yielded page owns the single main region,
loading status, and noscript content. Do not wrap it in another main or duplicate
its root ID. Full reload/no-cache metadata are intentional for the isolated viewer;
this layout does not supply application flash or a general purpose content container.

## Accessibility

The shared navigation is labelled and marks the current destination. The viewer
page supplies its own main landmark and loading feedback; its panels, controls,
and error announcements remain the viewer's responsibility. Preserve language,
direction, local typography, and readable noscript instructions. Keyboard/focus
behavior inside the viewer is verified by its existing project tests and must not
be replaced with navigation styling changes.
