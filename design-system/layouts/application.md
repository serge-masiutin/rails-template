---
sourcesHash: bcaa128c39e595b7da5b67ca96ee2fe14cae105f0e10343b85adb660ac82f155
id: application-layout
description: >-
  Frame ordinary server-rendered product and authentication pages with shared
  navigation, a constrained main region, flash feedback, and Native-aware chrome.
status: discoverable
sources:
  - app/views/layouts/application.html.erb
  - app/views/shared/_typography.html.erb
  - app/assets/tailwind/application.css
  - app/assets/stylesheets/typography.css
  - app/assets/stylesheets/ui_tokens.css
tests:
  - test/integration/navigation_test.rb
  - test/integration/localization_test.rb
  - test/system/authentication_test.rb
examples:
  - app/views/sessions/new.html.erb
  - app/views/home/index.html.erb
---

# Application layout

## When to use

- A server-rendered product page or authentication task needs the application's
  normal header, shared flash region, and centered content area.
- The same HTML also serves Hotwire Native; header suppression is presentation
  owned by this layout, while route access remains the controller's responsibility.

## When not to use

- The page belongs to administrator operations and needs their shared navigation;
  use [Admin layout](admin.md), or [Operations layout](operations.md) for AgentPrism.
- The surface is an email or a Lookbook preview; use its existing purpose-built
  mailer or component-preview layout rather than authenticated application chrome.

## Public API

Rails uses `layout "application"` through the normal controller convention. Pages
supply a body through `yield`, a translated `content_for :title`, and optional
`content_for :head` metadata. For example, the sign-in view sets its title and yields
one form section. The layout requires the normal ApplicationController helpers,
locale, Current authentication context, and realtime URL; it is not a standalone
renderable component.

The layout loads [shared tokens](../../app/assets/stylesheets/ui_tokens.css),
Tailwind, local typography, and the product importmap. No public class/theme/size
input exists; pages use supported components and normal local composition.

## Composition

Required order is skip link, optional web header/navigation, then `main#main`.
The main region contains the Turbo-temporary flash region followed by page content.
The layout owns the centered maximum width, outer padding, and navigation spacing.
Pages own their headings, body layout, and inner constraints; authentication uses
its narrower [form pattern](../patterns/authentication-form.md).

The header is omitted for Native presentation; ordinary web navigation shows
account/admin affordances only under the established authentication/policy checks.
Preserve these checks, subscriptions, CSRF/CSP metadata, and Turbo tracking. Do not
nest another `main` or duplicate the shared flash messages inside the yielded page.

## Accessibility

The layout sets language/direction and supplies a keyboard-reachable skip link to
`main#main`. It names primary navigation. Pages supply one meaningful heading and
properly associated controls. [Notice](../components/notice.md) owns feedback roles;
no second live announcement of the same flash should be added by a page.
