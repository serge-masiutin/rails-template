---
name: ui-catalog-setup
description: "Maintain the development-only ViewComponent/Lookbook catalog."
metadata:
  upstream: sb-setup
  adapted-for: StarterApp
  version: "5"
---

# ui-catalog-setup

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Check the lookbook gem, development-only mount and `view_component.previews.paths`.
- Keep previews in `test/components/previews` with deterministic inputs and no production database or network dependencies.
- Use the `component_preview` layout with real Tailwind assets, `shared/typography` (Martian Mono), importmap and Stimulus. Configure `view_component.previews.default_layout` in development; previews must not depend on a user session.
- Organize by component and meaningful states: normal, long text, error and disabled.
- Verify `/lookbook` in development and its absence in production.
- Render at least one preview, run its component test and record a significant setup result in `docs/intent-log.md`.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-setup.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-setup`.
