---
name: lookbook-setup
description: Set up or repair StarterApp ViewComponent previews and Lookbook discovery, layouts, assets, controls, and development-only access. Use when the catalog is missing or misconfigured.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Setup — Use the Installed Framework

## Bootstrap

Read the installed ViewComponent/Lookbook versions and current configuration first.
StarterApp already has Lookbook, a development route, previews under
`test/components/previews`, and the `component_preview` layout.

For a genuinely missing Rails catalog in an authorized setup task, follow the official
installed-version ViewComponent/Lookbook setup and add only necessary gems/configuration.
Inspect generator output before overwriting files. Existing project setup takes priority
over a generic scaffold.

## Align and Verify

1. Verify the development-only route and preview discovery paths.
2. Check `config.view_component.previews.default_layout = "component_preview"` and
   inspect the actual layout, including assets, CSRF/CSP where needed, and typography.
3. Ensure Tailwind scans views, components, and previews; no missing-class workaround
   should create a second stylesheet/token system.
4. Load required Stimulus behavior through existing importmap conventions. Avoid opening
   production subscriptions or requiring a real authenticated admin to render a primitive.
5. Render an existing real preview (`Ui::NoticeComponentPreview`) and confirm text/variant
   behavior. Discovery and successful rendering are separate checks.
6. Add useful controls with the installed Lookbook annotations; verify the values reach
   the actual component and don't allow unsupported variants.
7. For whole-page previews, supply the real view inputs and explicit layout/request
   context. Don't solve every missing helper by globally monkey-patching Rails state.

## Where Files Belong

The project already chose its location; don't ask again or scatter a new tree. Production
components remain in `app/components`; previews remain in `test/components/previews`.
Preview-only templates/helpers/experiments stay under test/support or the existing preview
tree and must not become production dependencies. Check autoload/discovery for any new
support location rather than claiming it is automatically loaded.

Configure preview discovery, rendering context, importmap assets, and Lookbook controls.
Inspect Rails source and confirm the resulting previews in a browser.

## Completion

Verify at least one real preview through the running catalog after configuration changes,
including a narrow viewport and local font. Report the exact check and any unavailable
runtime. Route to `lookbook-inventory` before generating broad coverage, then
`lookbook-previews` for one real component at a time.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
