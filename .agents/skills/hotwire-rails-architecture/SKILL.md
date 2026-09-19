---
name: hotwire-rails-architecture
description: "Design Rails and Hotwire features that serve both web and Android."
metadata:
  upstream: inertia-rails-architecture
  adapted-for: StarterApp
  version: "5"
---

# hotwire-rails-architecture

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `docs/architecture.md`, `docs/native.md`, routes, models, layouts and existing components.
- The server owns data, authorization, routing and validation. Share presentation through ERB/ViewComponent.
- Use Turbo Drive for navigation, Frames for independent regions and Streams for targeted DOM changes.
- Use AnyCable/Turbo Streams between clients. Authorize subscriptions in the channel; the current private stream is `UserUpdatesChannel`. See `docs/realtime.md` for history and session revocation.
- Register `turbo-cable-stream-source` exactly once through `@anycable/turbo-stream`; do not also load JS `@hotwired/turbo-rails`.
- Publish admin signals after commit through `Operations::Updates`; coalesce relevant events, refresh on reconnect/visibility return and preserve selection. Do not introduce periodic browser polling.
- Use Stimulus for local interaction and Native Bridge for device capabilities.
- Define one user journey and its HTTP contract before implementing all affected clients.
- Read `hotwire-rails-forms`, `hotwire-native-components` or `hotwire-rails-testing` as needed.
- Verify the shared journey in ordinary HTML, Turbo and Native navigation; report any untested platform behavior.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-architecture.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-architecture`.
