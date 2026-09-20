---
name: hotwire-rails-setup
description: Detect and align StarterApp Rails, Turbo, Stimulus, importmap, ViewComponent, Lookbook, and Android setup when bootstrapping or changing the stack. Preserve existing project configuration.
---

# Hotwire Rails Project Setup

Detect the actual stack, resolve only necessary missing capabilities, align project
instructions, and verify the resulting setup. Run when the stack changes, not before
every feature. Read the existing configuration before generating anything.

## Never

- Do not infer the application frontend from `package.json` alone: StarterApp uses React
  for the isolated AgentPrism viewer while product pages use Rails/Hotwire.
- Add dependencies only for a concrete capability required by the task.
- Do not overwrite user-maintained instructions or rerun generators over customized files.
- Do not declare a command verified unless it was actually run in this environment.

## Step 1: Detect Current Stack

Read declarations and lockfiles together. Declarations show intent; lockfiles show the
resolved API/version. Inspect the entrypoints that actually execute.

| Source | Establish |
| --- | --- |
| `.ruby-version`, mise config, `Gemfile.lock` | Ruby/Rails and installed gem versions |
| `Gemfile`, `config/application.rb` | Enabled frameworks and environment groups |
| `config/importmap.rb`, `app/javascript/application.js` | Product JS pins and startup |
| `package.json`, lockfile, viewer build files | Separate Node tooling and AgentPrism scope |
| `app/assets/tailwind/application.css` | Tailwind source scanning and semantic tokens |
| Layouts and `app/components` | CSRF/CSP, typography, components, native chrome |
| `config/environments/development.rb`, preview paths | Lookbook and preview layout |
| ApplicationController, policies, Authentication | Actual access contract |
| `test/test_helper.rb`, browser driver, `bin/ci` | Minitest and integration checks |
| Native Gradle files and versioned configurations | Android SDK/framework and path rules |
| `docs/architecture.md`, `docs/development.md` | Project decisions and operational setup |

StarterApp currently uses Rails, Turbo, Stimulus, importmap, Tailwind, ViewComponent,
Lookbook, Action Policy, Active Delivery, AnyCable, and Minitest. Verify versions from
the checkout rather than copying version numbers from this skill.

## Step 2: Resolve Missing Capabilities

Present only gaps relevant to the requested outcome. Keep existing conventions.

| Need | First choice | When extra setup is justified |
| --- | --- | --- |
| Page rendering | Rails ERB/ViewComponent | Existing stack is missing/broken |
| Local interactions | Stimulus/importmap | A specific browser capability needs a package |
| Upload progress | Active Storage direct-upload client | Product requires actual byte progress |
| Pagination | Existing bounded server query | Repeated pagination needs justify a library |
| JSON boundary | Explicit allowlist/schema | Several consumers justify a serializer/generator |
| Component catalog | Existing Lookbook | Catalog missing or loading incorrect assets |
| Native action | Existing bridge framework | Concrete device action requires a new component |
| Real-time update | Existing AnyCable client | New authorized channel/event contract |

Do not create new approval rituals for already authorized dependency changes. For a
substantial optional stack choice outside the request, show the concrete tradeoff before
installing. Never publish or deploy as a side effect of setup.

## Step 3: Align the Installation

Use pinned project tooling through mise. Inspect a generator's available options and
existing output before running it. Preserve local configuration and review the diff.

- Import Turbo once. The application uses `@hotwired/turbo`; AnyCable supplies its stream
  source integration. Preserve `cable`, controllers, and Native bridge startup.
- Keep `pin_all_from`/controller registration consistent. Don't add npm bundling just
  to resolve an import that belongs in the existing importmap.
- Keep Tailwind's explicit source list covering views, components, and previews. Use
  tokens from `@theme`; preserve local Martian Mono in web and native resources.
- Lookbook stays development-only and uses the configured preview layout. Follow
  `lookbook-setup` for discovery and real rendering checks.
- New direct uploads need both the Rails matching JS client and storage/CORS/access
  configuration; the helper attribute alone does not start the client.
- Native contract changes require synchronized published/bundled configuration and
  compatibility with installed clients; see `docs/native.md`.

## Step 4: Update Existing Agent Instructions

StarterApp uses root `AGENTS.md`. Read it first and update only
the affected routing/stack facts. Do not generate a competing CLAUDE.md stack block.
Use [stack-configuration.md](references/stack-configuration.md) to select applicable
categories. Refer only to installed skills and actual dependencies.

## Troubleshooting

| Symptom | Inspect | Correct direction |
| --- | --- | --- |
| Stimulus action never fires | Controller filename, loader, identifier, console | Repair registration/markup contract |
| Missing classes in previews | Tailwind source list and preview assets | Include real preview sources in existing pipeline |
| Duplicate stream-source behavior | JS imports/client startup | Preserve single AnyCable integration |
| Preview works only as static markup | Preview JS/layout | Load necessary actual local interactions |
| Native config drift | Published JSON versus bundled copy | `bin/native sync`, then check |
| Instructions disagree | Existing AGENTS/doc sections | Keep one source of truth, fix incoming links |
| JSON type generator missing | Gem/package manifests | Use explicit existing schema; don't claim auto-generation |

## Step 5: Verify and Summarize

Choose checks for the changed configuration: boot/zeitwerk, relevant request/browser
tests, assets, `bin/native check`, and `bin/ci` as appropriate.
Use the current commands in project docs/CI; record failures and environment limits.
Report what changed, which skills apply, what was verified, and any optional capability
that remains uninstalled. Do not call setup complete while a required entrypoint fails.
