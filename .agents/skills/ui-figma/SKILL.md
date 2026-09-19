---
name: ui-figma
description: "Implement approved Figma designs with project tokens, ViewComponent, Stimulus and Native UX."
metadata:
  upstream: sb-figma
  adapted-for: StarterApp
  version: "4"
---

# ui-figma

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Obtain the actual design and dimensions; never invent missing source properties.
- Map colors, spacing and typography to existing `@theme` tokens.
- Find a suitable component before creating one; preserve semantic variants.
- Implement approved design in ERB/ViewComponent, interaction in Stimulus and platform chrome in Kotlin.
- Add realistic previews and check responsive layout, labels, focus and touch.
- Report the design source, token mapping and verified differences. Publishing to Figma requires a user request.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-figma.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-figma`.
