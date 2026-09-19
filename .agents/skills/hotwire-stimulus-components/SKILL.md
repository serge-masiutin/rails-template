---
name: hotwire-stimulus-components
description: "Build focused Stimulus components with correct Turbo lifecycle cleanup."
metadata:
  upstream: shadcn-vue-inertia
  adapted-for: StarterApp
  version: "4"
---

# hotwire-stimulus-components

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Use `app/javascript/controllers`, explicit targets/actions/values and ERB data attributes.
- Give each controller one local UI responsibility; keep domain rules and permissions on the server.
- Use `event.currentTarget` and declared contracts instead of arbitrary globals.
- Release listeners, observers and timers on disconnect; reconnect must not duplicate handlers.
- Update aria-expanded/hidden and focus with visual state.
- Check interaction in Cuprite after initial load and Turbo Back/Forward navigation.
- Put device capabilities in BridgeComponent and coordinate with Kotlin.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/shadcn-vue-inertia.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/shadcn-vue-inertia`.
