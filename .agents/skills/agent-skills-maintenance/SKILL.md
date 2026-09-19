---
name: agent-skills-maintenance
description: "Adapt, validate and maintain project skills while preserving Evil Martians provenance."
metadata:
  upstream: skills-visibility
  adapted-for: StarterApp
  version: "6"
---

# agent-skills-maintenance

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- The registry is `config/agent_skills.json`: `skills` records upstream adaptations and hashes; `project_skills` lists original project skills. Originals live in `vendor/agent-skills/evilmartians`.
- Review the whole instruction path: SKILL.md, references, examples, workflows and scripts. Check examples against lockfiles, code and tests; update outdated APIs. Valid frontmatter does not prove semantic correctness.
- Keep working instructions in `.agents/skills` aligned with this stack and written in English.
- Compare upstream and local versions; preserve useful intent while adapting React/Inertia assumptions to Hotwire and Native.
- Give each skill a narrow trigger, explicit inputs, paths, context and a verifiable outcome.
- Add a skill only for a distinct recurring task; update an existing one when responsibilities overlap. On removal, update the registry, AGENTS routing and links.
- Keep secrets and complete user documents out of instructions.
- Increment metadata.version, run `bin/skills check`, check links and affected cases in `docs/agent-skills.md`, and report validation limits.
- An upstream update never overwrites working instructions automatically.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/skills-visibility/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/skills-visibility`.
