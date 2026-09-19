---
name: ui-comparisons
description: "Compare component variants, states and responsive behavior in Lookbook."
metadata:
  upstream: sb-wrappers
  adapted-for: StarterApp
  version: "4"
---

# ui-comparisons

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Compare variants with identical input and viewport sizes.
- Use ViewComponent preview templates for state grids; do not duplicate the component implementation.
- Group meaningful states only: normal, long content, error and disabled.
- Check semantic DOM and focus as well as appearance.
- For web/Native comparisons, identify Rails-rendered content versus platform navigation.
- Deliver a comparable preview and a concrete decision with verified limits.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-wrappers.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-wrappers`.
