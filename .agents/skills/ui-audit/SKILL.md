---
name: ui-audit
description: "Review UI usage, preview drift and missing states."
metadata:
  upstream: sb-audit
  adapted-for: StarterApp
  version: "4"
---

# ui-audit

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Compare actual render calls with previews and tests.
- Find obsolete variants, unused components and preview/production markup drift.
- Use `ui-health` for tokens and `ui-flows` for navigation.
- Separate confirmed defects from suggestions; give a scenario and file path for each defect.
- Keep fixes local rather than rewriting global styles.
- Update previews, tests and affected contracts together.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-audit.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-audit`.
