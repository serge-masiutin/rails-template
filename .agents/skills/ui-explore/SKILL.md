---
name: ui-explore
description: "Prototype UI changes in isolated development-only ViewComponent previews."
metadata:
  upstream: sb-explore
  adapted-for: StarterApp
  version: "4"
---

# ui-explore

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Establish the user task and existing tokens/components.
- Put prototypes in development-only previews, not unapproved product routes.
- Compare options with identical content, widths and states.
- Consider touch, keyboard, loading/errors and Native layout effects.
- Before shipping, settle the component API, tokens, accessibility and a testable journey.
- Use `ui-ship` for integration; keep useful previews rather than abandoned prototype collections.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-explore.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-explore`.
