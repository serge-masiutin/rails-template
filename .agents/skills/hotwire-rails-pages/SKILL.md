---
name: hotwire-rails-pages
description: "Build pages, navigation, filters and updates with ERB, Turbo and Stimulus."
metadata:
  upstream: inertia-rails-pages
  adapted-for: StarterApp
  version: "5"
---

# hotwire-rails-pages

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read the application layout, routes and `docs/hotwire.md`.
- Use `config/locales/en.yml` through `t`, `l` for dates and `count` for plurals; see `docs/architecture.md#interface-languages`.
- Set page titles with `content_for :title`; retain semantic headings and main content in Native.
- Use `link_to` for navigation and forms/`button_to` for mutations. Keep filters and pagination in the query string.
- Use stable frame IDs for independent regions and stream templates for multiple targets. For shared admin updates, reuse authorized AnyCable signals and the coalescing live-updates helper.
- Extract repeated markup into ViewComponent with a small explicit API.
- Clean up subscriptions/timers on disconnect and temporary DOM before `turbo:before-cache`.
- Test Back/Forward, reload with query parameters, Native back navigation and absence of duplicate navigation bars.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-pages.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-pages`.
