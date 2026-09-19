---
name: ui-hub
description: "Choose the appropriate ViewComponent/Lookbook design and review workflow."
metadata:
  upstream: sb-hub
  adapted-for: StarterApp
  version: "4"
---

# ui-hub

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Inspect routes, views, components, previews and design tokens.
- Start new UI with `ui-inventory`, prototypes with `ui-explore`, and approved Figma work with `ui-figma`.
- Lookbook `/lookbook` is development-only; check product pages through Rails.
- For a new UI system, follow inventory → tokens/health → previews → system tests → audit.
- Each step identifies actual files and the next necessary artifact; do not create process documents without a reader need.
- Completion means a component is used, represented in the catalog and verified in web and relevant Native journeys.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-hub.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-hub`.
