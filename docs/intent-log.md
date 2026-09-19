# Decision log

Record decisions that still affect maintenance, verified outcomes and outstanding work.
Keep operational instructions in their respective guides; Git history and PRs hold implementation history.

## 2026-09-19 — template foundation

- `bin/configure` renames source code, Android packages, configuration, metrics, documentation and skills in a clean checkout. See [the template contract](template.md).
- A configured AcmePortal copy passed setup, CI, production assets, Docker build and Android Debug/unsigned Release/lint. Device navigation and production deployment were not tested.
- Cuprite configuration belongs in Rails `driven_by`; a regression test verifies the registered browser options. See [testing](testing.md).
- Application UI and email publish only `en`; adding other languages requires a complete dictionary, explicit allowlist and client checks. All authored template content is English.
- Admin tools share session-based administrator access and navigation. Health and metrics keep separate machine authentication contracts.
- Admin updates use authorized AnyCable signals after commit, coalesced snapshot fetches and Turbo morph. There is no periodic browser polling; selection and access revocation are covered by browser and real transport tests.
- `bin/dev` starts local Prometheus, Grafana, Loki and Alloy. Ordinary logs stay outside PostgreSQL; JSON file/container rotation is bounded. AI execution records have a separate sanitized schema and retention.
- Production authentication, alert delivery, SMTP/LLM credentials and device validation remain deployment tasks; local checks do not establish production readiness. See [deployment](deployment.md).

- Local Alloy runs on the host under Overmind, avoiding stale open-file reads across Docker Desktop mounts. Mise pins its version; Loki is bound to loopback.

## 2026-09-19 — developer navigation and worker reload

- Added development-only links to Lookbook, mail previews, Rails routes and Alloy; mail previews use an unsaved example account.
- Reproduced stale Solid Queue models/callbacks after Active Job reload. The standalone worker now keeps its classes until restart; web reloading remains enabled.
- `test/lib/jobs_boot_test.rb` checks the real development worker boot and reload boundary in a separate process.
