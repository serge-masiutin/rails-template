# Rails Template design

The starter provides authentication, an account page, an admin dashboard, and
operations tools through server-rendered Rails/Hotwire HTML shared with Android.
Its baseline is the existing light palette and local Martian Mono. There is no
external Figma specification or theme switcher. Follow [AGENTS.md](AGENTS.md) and
[Hotwire conventions](docs/hotwire.md) for implementation and interaction behavior.

## Sources and scope

- [Components](design-system/COMPONENTS.md), [layouts](design-system/LAYOUTS.md),
  and [patterns](design-system/PATTERNS.md) route to their public contracts.
- [Token roles](design-system/tokens.md) explain the values in
  [ui_tokens.css](app/assets/stylesheets/ui_tokens.css).
- [Tailwind](app/assets/tailwind/application.css) exposes semantic utilities;
  [typography](app/assets/stylesheets/typography.css) supplies the shared font;
  [admin styles](app/assets/stylesheets/admin_navigation.css) use the same tokens.
- [Lookbook previews](test/components/previews) render actual ViewComponents.
  `/lookbook` is available only in development.

A contract documents when and how to use a reusable UI entity. ViewComponents are
components; Rails layouts own page shells; patterns describe composition recipes
without requiring new Ruby classes. Pages are consumers, not automatically patterns.
The catalog covers project UI primitives and shared shells. AgentPrism and Mission
Control retain their own internal libraries and upgrade procedures; their integration
shells are covered here, not a migration of vendor/gem internals into product UI.

## Shared rules

- Select an existing contract before copying presentation. Components own internal
  styling; consumers own content, page composition, and spacing between regions.
- Use tokens by role. Admin navigation and connection indicators have explicit
  roles with preserved values; a matching color does not make roles interchangeable.
- Authentication fields use the Rails form builder so native names, IDs, values,
  autocomplete and validation constraints remain intact. Supply field errors explicitly
  for unbound forms. Never repopulate a password from a failed request.
- A form's main action uses `Ui::SubmitComponent`; the enclosing form owns URL,
  HTTP method, CSRF and validation. Plain navigation stays a native link.
- Use translated UI strings from `config/locales/en.yml`, preserve Turbo/Native
  contracts and keyboard/focus behavior. Design work does not move authorization,
  request processing or interaction state into components.
- Preserve the existing light appearance when extending the catalog. Prefer the
  existing Tailwind spacing scale and supported component inputs over new variants
  or arbitrary class/style overrides.

## Development and verification

Follow [development](docs/development.md), [testing](docs/testing.md),
[Hotwire UI](.agents/skills/hotwire-ui-components/SKILL.md) and
[Lookbook previews](.agents/skills/lookbook-previews/SKILL.md).
[design-system](.agents/skills/design-system/SKILL.md) owns contract structure,
selection and source correspondence, while these project procedures own engineering.

Run from the repository root through `mise exec --`:

```sh
bin/design-system-check
node .agents/skills/design-system/scripts/generate-indexes.mjs .
bin/rails test test/components test/controllers/sessions_controller_test.rb test/controllers/passwords_controller_test.rb
bin/rails test:system
bin/ci
```

CI runs `bin/design-system-check` to validate contract metadata, local links, source
snapshots and generated indexes. After source changes, review the public promise,
then update the affected snapshot and indexes:

```sh
node .agents/skills/design-system/scripts/check-contract.mjs --update-sources-hash design-system/components/field.md
node .agents/skills/design-system/scripts/generate-indexes.mjs .
```
 A matching hash is not proof of behavior. Exercise actual catalog states,
invalid forms, disabled controls, keyboard behavior and narrow screens in the browser.

