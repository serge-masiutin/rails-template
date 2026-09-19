---
name: dependency-supply-chain
description: "Maintain Ruby, JavaScript, CI/CD and Android dependencies with verified provenance."
metadata:
  upstream: secure-npm-package
  adapted-for: StarterApp
  version: "10"
---

# dependency-supply-chain

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read actual manifests, lockfiles and official release notes before updating.
- Vendor AgentPrism UI/data/types from one commit with its license and SHA-256: npm data can lag UI. Update all three together and run type/provenance checks, builds and browser tests. Node/node_modules belong only in the build stage; runtime receives JS/CSS.
- Preserve justified compatibility constraints: current Node LTS must agree across Docker/mise/package.json; panels v3 moves with compatible AgentPrism upstream. See `docs/development.md` and `docs/agents.md`; do not remove constraints just to close a PR.
- ImageProcessing 2 requires explicit `ruby-vips`. AGP 9 uses built-in Kotlin without kotlin-android; update compiler, Gradle wrapper/checksum and dependency lock together, then build Debug/Release and run lint.
- Lockfiles, `config/agent_skills.json` and Gradle checksums own versions/integrity.
- The gem contracts are in `docs/architecture.md`: Abstract Notifier comes through Active Delivery; Bootsnap freezes literals instead of Freezolite.
- Coordinate Active Agent/RubyLLM updates. Local `StarterappProvider` adapts tokens/finish_reason and schema/provider_options tools for RubyLLM 2; remove it when upstream supports that contract. Verify usage, errors, schemas and streaming against installed code. Successful bundling is not compatibility proof; do not restore vulnerable RubyLLM 1.16 (CVE-2026-67991).
- After Ruby updates, check extracted stdlib gems: Sniffer/Isolator need `benchmark`. Preserve boot and transaction checks.
- Use bundler-audit, importmap audit, npm audit, Brakeman and Dependabot.
- Herb CLI/LSP/formatter are devDependencies installed through `npm ci` with project install scripts disabled. Run local bin commands without npx downloads. Update Herb as a group with its gem/config; check lint and LSP.
- CI reads Node from package.json. Ruby LSP and Lefthook are development-only; keep them and node_modules out of production.
- Pin GitHub Actions to commit SHAs, minimize permissions and withhold production secrets from PR checks.
- Update Native SDKs with consumers and Android builds; preserve released server contracts.
- Deploy through Kamal's protected production workflow. Never expose secrets through images, build arguments or logs.
- TestProf/StackProf belong in the test bundle; k6 uses the image pinned in compose.yml. After upgrades, verify Minitest integration, sql/cpu profiles, k6 smoke and cleanup.
- Run affected tests/builds; publish packages or applications only when requested.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/secure-npm-package/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/secure-npm-package`.
