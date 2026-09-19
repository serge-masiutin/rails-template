---
name: intent-log
description: "Record significant decisions and the state of sustained work for the next contributor."
metadata:
  upstream: intent-log
  adapted-for: StarterApp
  version: "5"
---

# intent-log

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `docs/intent-log.md`, actual changes and `clear-writing`.
- Record significant decisions and handoff state; a minor edit does not need an entry.
- Under a date, retain only the intent, outcome, checks, open questions and next step needed by the next contributor.
- Link the authoritative guide instead of copying commands or the stack description.
- Date validation results. An old successful run does not validate current code.
- Remove repetition and intermediate attempts; preserve reasons that still affect the project.
- Link PRs/commits only after they exist. State unpublished status when it affects the next step.
- Exclude transcripts, secrets, personal data and private reasoning.
- The handoff is complete when another developer can locate the relevant files and continue.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/intent-log.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/intent-log`.
