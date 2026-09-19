---
name: ui-ship
description: "Integrate an approved UI prototype into production ERB/ViewComponent screens."
metadata:
  upstream: sb-ship
  adapted-for: StarterApp
  version: "4"
---

# ui-ship

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Locate the selected variant, completion criteria and current call sites.
- Reuse a matching component contract or add a small named component.
- Move approved tokens, states and accessibility together with real page changes.
- Keep the preview as public API documentation.
- Remove unused experiment code in the same change; preserve the decision source in the PR.
- Run component/system tests and the relevant Native journey; report anything not executed.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-ship.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-ship`.
