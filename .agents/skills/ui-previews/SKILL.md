---
name: ui-previews
description: "Document meaningful component states with deterministic ViewComponent previews."
metadata:
  upstream: sb-stories
  adapted-for: StarterApp
  version: "4"
---

# ui-previews

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read the component API, usage, tokens and existing previews.
- Add methods for materially different states, not every parameter combination.
- Use deterministic short/long text, explicit variants, errors and disabled states.
- Each preview shows one clear scenario; extract repeated inputs only when repetition is real.
- Previews do not replace assertions; add a component test for the public contract.
- Check narrow/mobile viewports and keyboard interaction; Native navigation requires an application check.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-stories.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-stories`.
