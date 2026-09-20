# Layouts — Detailed Reference

## Why Shared and Persistent Layouts

Rails layouts prevent duplicated chrome and make typography, navigation, flash, locale,
and assets consistent. Turbo persistence solves a narrower problem: keeping a specific
DOM resource alive across visits, such as an active media player. Don't confuse these.

## Single and Default Layout

`app/views/layouts/application.html.erb` is the product default. Inspect it before adding
another wrapper. Use `content_for` for title or named sections and render components
for repeated chrome. Pass view inputs explicitly; components should not discover domain
records or make network calls during rendering.

```erb
<% content_for :title, t("reports.title") %>
<section aria-labelledby="reports-heading">
  <h1 id="reports-heading"><%= t("reports.title") %></h1>
  <%= render "reports/list", reports: @reports %>
</section>
```

## Nested Layouts

Use an existing partial/component for nested navigation when it is only markup. Use
Rails nested layouts only when a group truly needs another layout contract. Keep one
HTML document head, CSRF/CSP configuration, font inclusion, and JS initialization.
Do not render the complete application layout inside a frame or component preview.

## Conditional Layouts and Opting Out

Choose a layout on the server by the route/controller's presentation needs. Admin pages
inherit `Admin::BaseController`; they retain AdminPolicy, common navigation, and no-store.
Authentication and error screens must still render complete valid documents when
visited directly. A frame-specific rendering can omit outer chrome but must include
the matching frame. API/download responses have their own explicit formats.

Native presentation can hide duplicate browser chrome through existing Native helpers;
it never bypasses authentication or authorization. Don't choose a less protected
controller merely because the request looks like a WebView.

## Layout with Shared Data

Render current-user display and navigation from the established request context and
policy helpers. Avoid leaking emails/roles/session data into global JS unless an actual
UI contract requires those fields. `allowed_to?` hides a control; `authorize!` still
protects its endpoint. Keep repeated query costs visible and covered by N+1 checks.

## Permanent Elements

Both documents need an element with the same unique ID and `data-turbo-permanent`.
Understand what is intentionally stale: Turbo preserves the old DOM instead of replacing
it with newly authorized/rendered values. Never keep private content across logout or
role changes by accident. Define explicit lifecycle/reset behavior for the retained
resource; don't put the entire application shell inside one permanent element.

## Scroll Regions

Default browser page scrolling is easiest to restore. If a panel owns scrolling, identify
the element, save/restore only the relevant state, and test Back/Forward and anchor links.
Avoid nested full-height scroll containers unless the design needs them. Keep focus
visible after validation and navigation, including the Android soft keyboard.

`data-turbo-action` governs visit history for frame navigation; it is not an arbitrary
scroll-position API. If a feature needs custom scroll preservation, implement and test
that exact behavior without globally overriding browser/Turbo navigation.

## Preview Layout

Lookbook uses the configured `component_preview` layout. It must include the actual
Tailwind assets and local Martian Mono, with the same token contract. Keep application
authentication, production subscriptions, and heavy operational boot code out of isolated
component examples. Screen previews can explicitly compose the needed chrome and data.
