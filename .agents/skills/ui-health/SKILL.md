---
name: ui-health
description: "Audit design tokens, Tailwind and interface accessibility."
metadata:
  upstream: sb-health
  adapted-for: StarterApp
  version: "4"
---

# ui-health

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `app/assets/tailwind/application.css`, components and real call sites.
- Find repeated magic values, constructed class names, missing semantic tokens and conflicting variants.
- Check contrast, focus-visible, ARIA state, labels, touch targets and long translated text.
- Search templates, previews and JS before removing a token.
- Use `tailwind-best-practices` for fixes and `ui-previews` to demonstrate states.
- Report concrete paths, a reproducible case and the smallest correction.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-health.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-health`.
