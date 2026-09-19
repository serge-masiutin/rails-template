---
name: ui-flows
description: "Map real routes and user journeys across web and Android."
metadata:
  upstream: sb-flows
  adapted-for: StarterApp
  version: "4"
---

# ui-flows

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `config/routes.rb`, `bin/rails routes`, links/forms/redirects and Native path configuration.
- Identify public/protected screens, GET navigation, mutations, modals and sign-in return paths.
- Ensure web navigation does not duplicate native chrome and both clients can reach account/logout.
- Use a small Mermaid diagram with HTTP statuses and authorization boundaries for an unclear journey.
- Check Back/Forward, modal dismissal, invalid forms and expired sessions.
- Distinguish existing routes from proposed product screens.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/sb-flows.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/sb-flows`.
