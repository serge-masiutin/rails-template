---
name: good-readme
description: "Maintain concise, reproducible README and documentation with one authoritative source per topic."
metadata:
  upstream: good-readme
  adapted-for: StarterApp
  version: "5"
---

# good-readme

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Help the reader run, change or operate the current project. Read `clear-writing`, affected docs and their source configuration, commands, tests, routes and builds.
- Find the existing guide and incoming links with `rg` before adding documentation.
- Update docs with each behavior, command or contract change. Create a file only for a distinct recurring reader task; otherwise use a section or link.
- Keep README to purpose, startup, checks and navigation. Put details in the relevant guide and link manifests instead of duplicating version lists.
- Remove stale instructions and duplication. Update incoming links when moving or deleting a file; retain history only for a supported contract or a current decision.
- Distinguish development, CI and production. Preserve prerequisites, side effects and limits.
- Put one-off validation results in the PR or a short dated `intent-log` entry, not a new report per step.
- Verify paths, links, ENV names and commands against code. Run changed commands or mark them unverified; ensure the reader can find the action and expected result.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/good-readme/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/good-readme`.
