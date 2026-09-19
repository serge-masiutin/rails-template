---
name: hotwire-rails-testing
description: "Test Rails contracts, ViewComponent, Cuprite, real services and Native behavior."
metadata:
  upstream: inertia-rails-testing
  adapted-for: StarterApp
  version: "17"
---

# hotwire-rails-testing

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Choosing coverage

- Use the risk/level matrix in `docs/testing.md`. Name the failure and observable result before writing a test; choose the lowest sufficient level. Coverage percentages and test counts are not goals.
- Extend a test that already owns the contract. Keep browser tests for critical journeys and JavaScript; keep validation matrices in Ruby/HTTP tests.
- Do not test dependency internals, private methods, cosmetic details or duplicate paths. Preserve our integration guards and known regressions, including worker reload and Cuprite setup.
- When removing a test, identify the remaining owner of the contract or why it belongs to upstream. Never remove a failure merely to get green CI.
- Use explicit fixtures and restore global state. Subprocess tests supply their own configuration; assert outcomes and absence of forbidden effects, not only HTTP 200 or no exception.

## Working contract

- Read `docs/testing.md` and existing `test/` conventions. Use Minitest and fixtures; WebMock blocks external HTTP and permits localhost for system tests.
- Start with the affected file, then the relevant suite and `bin/ci`. Report Ruby, browser and Android results separately; an APK build does not validate device navigation.
- Admin tests cover guest/user/admin access, role revocation, JSON 401/403, Mission Control CSRF and no-store. Browser sessions never replace machine Basic/Bearer credentials or vice versa.
- Live updates must arrive without clicks or idle polling, preserve input/selected trace, clear panels on access loss, pause fetches while hidden and clean up on disconnect. `test/frontend/live_updates_test.mjs` covers coalescing and single-flight requests; `bin/realtime-test` proves real queue/trace signals through AnyCable. Exercise queue commits, rollbacks and bulk operations.
- Test Active Agent through SDK local_store into sanitized JSON, usage without double counting, write failures, retention and administrator access. New SDK fields must not flow automatically into storage/RAW. Build AgentPrism before its browser tests.
- Run `bin/image-test` for real imgproxy transforms, dimensions/format, signatures, expiry and blocked external sources; URL unit tests cannot prove Go processing.
- AI tests cover HTTP request/response, usage, errors without retries, commit/rollback, request/job correlation and absent body logs. Each feature also needs versioned quality evals with typical, malformed and adversarial cases.
- Check English UI/email, lang, validation messages, locale rejection, missing translations and request isolation; see `test/integration/localization_test.rb`.
- Measure slow tests with `bin/test-profile sql` or `cpu` before optimizing; compare the same suite afterward. Profiles use one process; regular Linux CI remains parallel.
- Reproduce flaky failures with their seed. Fix state leaks, clocks and event synchronization; do not hide failures with retries or sleeps. Keep Cuprite JavaScript errors enabled.
- Keep Isolator enabled; test commit and rollback for side-effect changes. For actual commits use `self.use_transactional_tests = false` and clean up records.
- Check collections with `assert_perform_constant_number_of_queries` over growing datasets; see `test/models/queue_snapshot_test.rb`.
- Verify job delivery and unauthorized access to another user's records.
- Test races with real threads, barriers, timeouts, separate database connections and `Thread#value`; see `test/lib/concurrency_test.rb`. For our own context/resource handling, check cleanup after failure: Current, log tags and checked-out connections.
- Integration tests cover status, redirects, cookies, authorization, HTML and stable Turbo targets. ViewComponent tests check semantic DOM and variants.
- Register database pools before system fixtures, including `SolidQueue::Record`; creating a pool in Puma's thread breaks Isolator transaction accounting at teardown.
- Set Cuprite through `driven_by ... options:`; Rails overwrites manual driver registration. `BrowserDriverTest` verifies real options; `process_timeout` controls Chrome startup, not DOM waits.
- Use Chrome/Capybara for form success, 422 error rendering, history and Stimulus reconnect when changing that client behavior. A browser scenario complements the HTTP validation matrix; do not repeat the full matrix in the browser.
- After WebSocket changes, `bin/realtime-test` checks Go delivery, recovery, history loss, foreign subscriptions and session revocation. Mocked broadcasts cannot prove delivery.
- `bin/load-test smoke|load` uses the local test database, a temporary user, CSRF and real private delivery. Never run it alongside other tests. Errors or missing delivery must fail thresholds; check cleanup and required JSON/metrics artifacts. Local results do not establish production capacity.
- Native checks validate schema/path rules and bundled/remote JSON agreement. Kotlin changes require an Android build; missing SDK is an unverified result, not success.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-testing.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-testing`.
