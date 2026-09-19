---
name: rails-serialization
description: "Design explicit JSON contracts for Native configuration and external integrations."
metadata:
  upstream: alba-inertia
  adapted-for: StarterApp
  version: "4"
---

# rails-serialization

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Identify the consumer first: ordinary pages use HTML; Native path configuration uses versioned JSON.
- Specify required fields, nullability, timezone, units and contract versions.
- Serialize selected fields explicitly; never expose a whole model through `as_json`.
- Preserve settings/rules, regex patterns and platform properties in `public/configurations/*_v1.json`.
- Exclude secrets, user records and internal URLs from public configuration.
- Preserve released mobile clients: publish incompatible formats as v2 while keeping v1.
- Test schemas, consumer cases and absence of extra fields; synchronize bundled JSON with `bin/native sync`.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/alba-inertia.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/alba-inertia`.
