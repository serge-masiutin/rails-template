---
name: hotwire-rails-controllers
description: "Implement authenticated HTML, Turbo Frame/Stream and Native controllers."
metadata:
  upstream: inertia-rails-controllers
  adapted-for: StarterApp
  version: "5"
---

# hotwire-rails-controllers

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `ApplicationController`, `Authentication` and `docs/hotwire.md`.
- Use `params.expect` for required form structure. Malformed parameters return 400; invalid values re-render the form with 422.
- Successful POST/PATCH/DELETE requests redirect to a known internal destination with 303.
- Frame responses retain the requested frame ID; Streams use stable `dom_id` and explicit targets.
- Authorize through Action Policy and `authorize!` before mutation or disclosure. Keep `verify_authorized` by default; exceptions require a separately tested access boundary, such as password/token checks in sessions/passwords.
- Collections need `authorized_scope` and `verify_authorized_scoped`; `authorize!` alone does not filter rows. Test other users' records.
- Send application notifications through deliveries instead of scattered mailer calls.
- Keep Rails cookies/CSRF for Native; User-Agent changes presentation, not access. Never put tokens in URLs.
- Cover guests, authenticated users, malformed input and success/failure responses; change existing statuses deliberately.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-controllers.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-controllers`.
