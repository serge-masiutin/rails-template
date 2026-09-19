---
name: ui-inventory
description: "Find UI components, duplicated markup and actual usage."
metadata:
  upstream: sb-inventory
  adapted-for: StarterApp
  version: "4"
---

# ui-inventory

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Inspect `app/components`, `app/views`, `app/javascript/controllers` and `test/components/previews`.
- Find render calls and Stimulus bindings for each candidate; a file alone does not prove usage.
- Distinguish design-system components, one-off screens, mailers and accidental duplication.
- Map variants to call sites and preview methods.
- Present a short table of components, usage, states and preview/test gaps.
- Propose consolidation based on stable meaning, not merely similar CSS classes.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-inventory.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-inventory`.
