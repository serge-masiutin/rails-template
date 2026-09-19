---
name: hotwire-ui-components
description: "Build reusable ViewComponent and Tailwind UI with explicit variants."
metadata:
  upstream: shadcn-inertia
  adapted-for: StarterApp
  version: "5"
---

# hotwire-ui-components

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Use local Martian Mono through shared typography; vary size, weight and spacing, not family. Test Cyrillic coverage, long text and narrow screens.
- Find existing components and tokens in `app/assets/tailwind/application.css` first.
- Put components in `app/components`, previews in `test/components/previews` and tests in `test/components`.
- Use keyword arguments and a fixed variant map; reject unknown variants with `fetch`.
- Keep complete Tailwind class literals; never construct names such as `bg-#{color}`.
- Preserve Rails escaping; do not mark user strings HTML-safe.
- Give buttons correct types, fields labels and dialogs focus management. Support touch and keyboard.
- Validate previews, semantic DOM and the user journey through Turbo.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/shadcn-inertia.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/shadcn-inertia`.
