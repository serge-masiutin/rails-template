---
name: hotwire-bridge-contracts
description: "Define and validate shared JSON contracts between Stimulus and Hotwire Native Android."
metadata:
  upstream: inertia-rails-typescript
  adapted-for: StarterApp
  version: "4"
---

# hotwire-bridge-contracts

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Inspect bridge APIs for the versions in `docs/native.md` and lock/build files.
- Define component name, events, required/optional fields, types, errors and valid responses.
- JavaScript BridgeComponent and Kotlin DTOs must implement the same JSON contract.
- Validate external messages once at the boundary. Invalid payloads produce observable errors without exposing sensitive values.
- Keep the HTML button usable when a native capability is unavailable: this is explicit progressive enhancement.
- Change JS, Kotlin and fixture payloads together; preserve compatibility with released applications.
- Test malformed payloads, unknown events, disconnect/reconnect, repeated taps and clients without the component.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-typescript/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-typescript`.
