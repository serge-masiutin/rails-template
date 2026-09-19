---
name: hotwire-rails-setup
description: "Maintain Rails/Hotwire setup, local processes, assets and environments."
metadata:
  upstream: inertia-rails-setup
  adapted-for: StarterApp
  version: "12"
---

# hotwire-rails-setup

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read versions from `.ruby-version`, `mise.toml`, lockfiles, Dockerfile and native build files.
- For a new application, run `bin/configure --name my_app --android-id com.example.myapp` in a clean checkout before setup. See `docs/template.md`; do not rename an existing application with this command.
- Start with `mise install`, `mise exec -- bin/setup`, then `mise exec -- bin/dev`.
- `bin/dev` starts Prometheus, Grafana, Loki and Alloy. Alloy runs on the host under Overmind; monitoring containers outlive Overmind; see `docs/observability.md` for configuration and shutdown. Never expose local anonymous Grafana or Loki as a production deployment.
- Overmind reads `Procfile.dev` for web, CSS, jobs, AnyCable, imgproxy, AgentPrism watchers and Alloy; Compose supplies PostgreSQL.
- Keep JSON file/container log rotation bounded. Suppress successful health/metrics summaries only; retain errors and denied requests. Ordinary logs belong in Alloy/Loki, not application tables.
- AnyCable uses HTTP RPC and a shared Rails/Go secret. Preserve private ports and Kamal accessory configuration; run `bin/realtime-test` after transport changes.
- Use importmap and vendored JS for the shared app; Tailwind builds through its Ruby gem. Node supports Herb and the isolated AgentPrism viewer.
- AgentPrism uses `npm run check:agents`, `npm run build:agents`, an Overmind watcher and a separate Docker build stage. Its operations layout loads the shared AnyCable entrypoint without giving Turbo ownership of React DOM. See `docs/agents.md`.
- Images use the shared `/images` endpoint with imgproxy, read-only storage, signed expiring URLs and restricted sources. See `docs/images.md`; run `bin/image-test`.
- `bin/setup` installs locked npm packages and local Lefthook. Keep editor/Git/SSH/shell settings project-local; see `docs/development.md`.
- Run Herb through `bin/erb-check`; RuboCop also checks README/docs Ruby examples. Format ERB explicitly with `bin/erb-format`, inspect the diff and test the screen; hooks must not auto-correct.
- `ConcurrencyConfig` owns thread/process counts, supervisor mode and database pools. Do not duplicate defaults; validate bad ENV, `bin/jobs check` and the connection budget in `docs/architecture.md`.
- Validate configuration once through Anyway Config or native Rails configuration with explicit required fields.
- After changes, check Zeitwerk, production assets, `bin/ci` and Overmind startup. Configure Native SDK/wrapper through `docs/native.md` without changing global shell profiles.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-setup.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-setup`.
