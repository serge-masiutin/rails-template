# Testing

Run `mise exec -- bin/setup --skip-server` first. PostgreSQL, Docker and Chrome are required.
Run the full suite with `mise exec -- bin/ci`.

## What to test, and at which level

Start with the risk: what incorrect behavior would a user or operator observe, and what data
could be lost or exposed? Each test needs a concrete failure scenario and an observable result.
Choose the simplest level that reproduces the risk; extend an existing test when it already owns
the contract. Neither coverage percentage nor test count is a target.

| Contract | Primary level and examples |
| --- | --- |
| Access rules, validation, data conversion | Ruby policy/model/parser tests: foreign records, invalid configuration, unsupported versions and value boundaries |
| Sign-in, password reset, routes, forms, HTML/JSON | HTTP integration: status, redirects, form fields, database state, authorization and side effects; do not call private controller methods |
| Atomicity, uniqueness, commit/rollback, races | Real PostgreSQL and our operation; concurrent calls with barriers/timeouts, without fixture transactions when a real commit is required |
| Jobs and external APIs | Serialization, request/job IDs, enqueue after commit, failures and attempt counts; replace HTTP/transport while retaining our adapter and SDK |
| ViewComponent and Stimulus | Semantic DOM, escaping and accessibility for components; timers, coalescing, cancellation and cleanup for JS, with controlled clocks and DOM boundaries |
| Turbo and critical user journeys | A few browser paths: sign-in and navigation without reload, JavaScript behavior, preserved input, revoked access and narrow screens; keep the full HTTP validation matrix below the browser |
| WebSocket, images, infrastructure | Short real AnyCable/imgproxy checks for signatures and delivery; native configuration and alert validators. A mocked broadcast does not prove delivery |
| Android | Shared HTTP/JSON contracts plus build/lint; Kotlin/bridge changes require the corresponding behavior to be checked on an emulator or device |
| AI | Deterministic adapter/tool/usage/error/privacy tests; assess output quality with a separate task dataset when adding a product AI feature |

Check authorization at each public boundary: HTTP and WebSocket protect separate entry points.
Multiple levels are justified when they catch different failures: a policy checks a rule, an HTTP
request checks enforcement, a browser checks the client, and the Go server checks delivery.
Keep error matrices at the lowest sufficient level.

## When not to add a test

- Documentation, comments, formatting or simple presentation changes without behavior changes:
  use the relevant linter, link check, build or visual inspection.
- The same contract is already protected at the same level: extend or run the existing test.
- The test exercises only Ruby/Rails/a gem: a standard getter, a library's unknown-method error,
  `FrozenError` semantics or a callback our code does not invoke.
- Assertions mirror implementation: private methods, internal call order, complete CSS class lists,
  whole-page HTML snapshots or exact link counts instead of required destinations.
- The only assertion is `assert_nothing_raised` or HTTP 200: identify and check the useful result.
  Status alone can be the contract for a health endpoint; a form also needs its action and fields.

Our integration with dependencies and known regressions are exceptions. Keep the Bootsnap,
external HTTP isolation, Cuprite and worker boot checks: they guard actual configuration and
previous failures, not the libraries' implementation. Small size is not a reason to delete a test.

Before removing a test, explain in the PR which test or native check retains the contract,
or why the contract belongs to a dependency. Where possible, reproduce the original defect for
a regression test: applying the fix must change its result. Do not delete a failure to make CI green.

## Test data and boundaries

- Use explicit fixtures such as `users(:one)`, not `User.take` or an arbitrary first record.
- Create only the required data. Other HTTP features may use `sign_in_as`; authentication and
  transport scenarios exercise real passwords, CSRF and cookies.
- Replace external boundaries rather than the logic under test. Add a real transport smoke where
  transport matters; PR tests must not require paid APIs or production credentials.
- Restore ENV, locale, configuration, clocks and subscriptions in ensure/teardown. Subprocess tests
  provide their own test configuration instead of using local secrets or development databases.
- Assert the negative side of the contract: another session survives, rollback sends nothing,
  and secrets do not reach logs. Absence of an exception is insufficient on its own.

## Check commands

| Layer | Tool and command |
| --- | --- |
| Models, jobs, policies, HTTP and components | Minitest: `mise exec -- bin/rails test` |
| Browser and Turbo | Capybara/Cuprite: `mise exec -- bin/rails test:system` |
| Real AnyCable delivery | Chrome and Go: `mise exec -- bin/realtime-test` |
| Real image transformations | imgproxy: `mise exec -- bin/image-test` |
| HTTP/WS load smoke | k6: `mise exec -- bin/load-test smoke` |
| Android contracts | `mise exec -- bin/native check`; [builds](native.md) |

Start with the changed test, then its related suite; run `bin/ci` and GitHub CI before merging.
Use profiles or additional seeds when changing setup/order or fixing instability; do not repeat
a green full run without a new reason. The short k6 smoke validates the harness and delivery;
longer load runs belong to an explicit Test diagnostics task.

## Test boundaries

Minitest randomizes order and prints the seed. The regular suite uses two processes on Linux
and one on macOS because of fork/Ruby 4/libpq compatibility. Cuprite raises JavaScript errors.
Wait for DOM changes with Capybara assertions rather than sleeps.

Set Cuprite options through `driven_by` in `ApplicationSystemTestCase`: Rails overwrites a
separate registration with the same driver name. Chrome startup has a 30-second timeout;
commands have 10 seconds. `BrowserDriverTest` checks the actual registered browser options.
Register primary and queue database pools before system fixtures so Isolator sees test
transactions open and close in the same thread. Failure screenshots go to `tmp/screenshots`
and CI artifacts.

WebMock blocks external HTTP while allowing localhost for the browser and local services.
Stub network boundaries and verify requests, responses, errors and attempt counts.
See `test/models/llm_test.rb` and `test/lib/http_isolation_test.rb`.

Active Agent tests cover templates, usage, queueing, failures and log privacy in
`test/agents/application_agent_test.rb`. Transport tests do not replace [AI quality evaluations](agents.md).
Use N+1 Control with growing datasets, as in `test/models/queue_snapshot_test.rb`;
installing the gem alone does not test every query. Keep Isolator enabled when testing side effects.

Authentication uses MemoryStore in tests so rate limits remain active; clear it between tests.
`PasswordResetAtomicityTest` creates a temporary foreign-key constraint in the test database
to verify that session deletion failure also rolls back the password change.

## Profiling

TestProf integrates with Minitest 6. Profiles run explicitly in one process:

```sh
mise exec -- bin/test-profile sql
mise exec -- bin/test-profile sql test/models/queue_snapshot_test.rb
mise exec -- bin/test-profile cpu
mise exec -- bundle exec stackprof tmp/test_prof/stack-prof-report-cpu-raw-total.dump --text --limit 20
```

`sql` reports SQL time and event counts by suite and test. `cpu` writes StackProf and JSON
reports under `tmp/test_prof`. Measure first, change fixtures/setup/queries, then repeat the
same profile. This project uses fixtures; FactoryBot optimizations are not needed.
The **Test diagnostics** GitHub workflow accepts `sql` or `cpu` and retains reports for seven days.

## HTTP and WebSocket load

```sh
mise exec -- bin/load-test smoke
mise exec -- bin/load-test load
```

The harness requires local `starter_app_test`. It creates a temporary user, starts separate
Rails/Puma, AnyCable and k6 processes, then removes its user, containers and processes.
Do not run it alongside other tests that share the database. Ports 3200, 8290 and 8291 must
be free. Rails listens on host interfaces at port 3200 during the run so containers can reach
it through the host gateway. No development or production server is required.

k6 signs in with CSRF and cookies, reads the workspace/profile, subscribes to a private stream
and checks actual Rails broadcasts. Origin checks and authorization stay enabled. Every
connection must receive a message; an empty run or a successful handshake alone cannot pass.

| Profile | HTTP VUs | WebSocket VUs | Load duration |
| --- | --- | --- | --- |
| `smoke` | 1 | 2 | 8 seconds |
| `load` | 5 | 20 | 30 seconds |

Startup and shutdown add time. The scenario is `test/load/scenario.js`; image versions live
in `compose.yml`. Thresholds require successful checks, no HTTP/WS errors and p95 below two
seconds for pages, subscriptions and delivery. These are harness checks, not product SLOs
or production capacity measurements: the test uses one account and runs on the same host.

Reports under `tmp/load-test/<profile>/` include the k6 JSON summary, Rails/Yabeda and AnyCable
metrics, and local server logs. Each run replaces that profile's reports. CI runs `smoke`;
**Test diagnostics → load** runs the longer profile. CI artifacts expire after seven days.
For development monitoring, see [Prometheus/Grafana](observability.md).

## Flaky tests

Reproduce the failure with its seed:

```sh
PARALLEL_WORKERS=1 mise exec -- bin/rails test test/system/authentication_test.rb --seed 12345
```

Inspect shared mutable state, clocks, record order, background work and DOM waits. Use scoped
time helpers, explicit fixture relationships and ensure/teardown cleanup. Test concurrency
with barriers and timeouts. Fix the cause instead of adding automatic retries or rerunning
until the suite happens to pass.

This is a project policy, not a universal ratio of unit/integration/system tests.
Sources: [Rails: when to use system tests](https://guides.rubyonrails.org/testing.html#when-to-use-system-tests),
[System of a test, Evil Martians](https://evilmartians.com/chronicles/system-of-a-test-setting-up-end-to-end-rails-testing),
[profiling and valuable optimizations](https://evilmartians.com/chronicles/railing-against-time-tools-and-techniques-that-got-us-5x-faster-results),
[Evil Martians testing stack](https://evilmartians.com/rails-startup-stack#testing),
[TestProf EventProf](https://test-prof.evilmartians.io/guide/profilers/event_prof),
[AnyCable, k6 and Yabeda](https://evilmartians.com/chronicles/real-time-stress-anycable-k6-websockets-and-yabeda),
[flaky tests](https://evilmartians.com/chronicles/flaky-tests-be-gone-long-lasting-relief-chronic-ci-retry-irritation).

## Admin and live updates

`test/integration/admin_test.rb` covers guest/user/admin access, role revocation, Mission Control
CSRF, Basic/Bearer isolation, heartbeat and real queue SQL failures. System tests cover sign-in
return paths, shared navigation and narrow screens with a Native User-Agent. Shared HTML tests
do not replace an Android device run.

`test/frontend/live_updates_test.mjs` checks event coalescing, a single in-flight request,
hidden-tab cleanup, reconnects and the absence of idle polling. Queue model tests exercise
real commits, rollbacks and bulk operations. The real AnyCable harness verifies live queue
and AgentPrism changes, preserved selection and access revocation through Go and Chrome.
Ordinary Rails system tests simulate signals; they cannot prove WebSocket delivery.

AgentPrism system tests cover the call tree, attributes, RAW, empty/error states and narrow
screens. Backend tests cover administrator access, pagination, retention and sensitive-field
removal. Run `npm run build:agents` before an isolated browser test; `bin/ci` builds it.

`test/integration/localization_test.rb` checks English UI/email, locale validation, links,
request isolation, adding a locale and failure on missing translations.

There are currently no automated Android device navigation tests or product AI evals.
A Native User-Agent in a browser and a successful APK build do not establish Android SDK behavior;
ProbeAgent tests the integration, not output quality. Add these checks with the corresponding feature.
