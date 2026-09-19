---
name: rails-boot-profiling
description: "Measure Rails boot time and optimize demonstrated require/initializer bottlenecks."
metadata:
  upstream: rails-boot-profiling
  adapted-for: StarterApp
  version: "4"
---

# rails-boot-profiling

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Reproduce slow boot with pinned Ruby and Gemfile.lock and save a baseline.
- Separate cold/warm Bootsnap, development/test/production and web/job processes.
- Profile require/initializers with an appropriate tool; add a profiler only for a concrete measurement.
- Look for development gems in production, boot-time IO and repeated configuration parsing.
- Do not hide network work in an initializer or accessor.
- Change one cause, repeat the same measurement and report commands/results.
- Check Zeitwerk, assets and tests after optimization. Preserve fail-fast configuration.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/rails-boot-profiling/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/rails-boot-profiling`.
