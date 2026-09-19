# Architecture

The foundation follows the [Evil Martians Rails Startup Stack](https://evilmartians.com/rails-startup-stack):
Rails, Turbo, Stimulus, importmap, Tailwind, ViewComponent, Anyway Config, and Overmind.
Lookbook previews components; Minitest and Cuprite test behavior.
[imgproxy](images.md) transforms images; Active Storage stores originals.
See [observability](observability.md) for Yabeda, JSON logs, and job operations.

Version sources: [.ruby-version](../.ruby-version), [Gemfile.lock](../Gemfile.lock),
[compose.yml](../compose.yml), and [Android build files](../native/android/app/build.gradle.kts).

## Code ownership

| Directory | Responsibility |
| --- | --- |
| `app/models` | Data and domain rules; complex operations in the model namespace |
| `app/controllers` | HTTP, parameters, authorization, and responses |
| `app/views`, `app/components` | Shared web and Android HTML |
| `app/javascript/controllers` | Stimulus behavior and lifecycle cleanup |
| `app/configs` | Typed and validated Anyway Config settings |
| `app/jobs` | Background work |
| `app/policies` | Action Policy authorization |
| `app/deliveries`, `app/mailers`, `app/notifiers` | Notification events, email, and other channels |
| `native/android` | WebView, mobile navigation, and device capabilities |

Add a layer only when it owns a concrete responsibility. Solid Queue and Solid Cache use PostgreSQL.
[AnyCable](realtime.md) serves WebSocket connections through Rails HTTP RPC, a Go server,
and one client shared by web and Android.

## Interface languages

The UI, email, documentation, comments, and working skills are English.
Application translations live in `config/locales/en.yml`; `config/application.rb` lists supported locales.
`Localization` accepts `?locale=en`, rejects unknown values with 400, and scopes the request with
`I18n.with_locale`. Browser language is not selected automatically. Links preserve locale;
responses set `Content-Language`, and layouts set `lang` and `dir`.

Use `t` in ERB, `I18n.t` in Ruby, `l` for dates, and `count` for plurals.
Translate complete sentences with named placeholders. `_html` keys may contain trusted dictionary markup;
never mark user input `html_safe`. Missing translations raise; cross-language fallback is disabled.
Active Job preserves locale at enqueue time; mailers use it for rendering and links.
Future notifications started outside HTTP must receive the recipient locale explicitly.

The AgentPrism shell receives a small Rails dictionary through escaped `data-messages`; JS validates it.
Embedded AgentPrism, Mission Control, and Lookbook currently use English. Localizing their UI is a separate
integration task; do not edit vendored sources. Static error pages in `public/` and Grafana dashboards also
use English and operate outside Rails i18n. Additional locales need their own pages/dashboards.

To add a language:

1. Add a complete `config/locales/<locale>.yml`, including Rails errors, field names, date/number formats,
   plural rules, and `layout.direction`. Use that language's rules, not English plurals for every language.
2. Enable it in `available_locales` only after checking forms, errors, email, dates, numbers, long text,
   accessibility, and missing keys.
3. Add Android `res/values-<locale>/strings.xml`; update `androidResources.localeFilters` and
   `res/xml/locales_config.xml`. Keep base `values/strings.xml` English. Synchronize an explicit app-language
   selection with the Rails URL; the OS language alone does not change it.
4. For RTL, verify direction, order, and logical spacing. Check Martian Mono glyph coverage and resolve
   missing glyphs before shipping a language.
5. Run `test/integration/localization_test.rb`, affected screen tests, `bin/ci`, and Android build/lint.
   The temporary French locale in tests verifies extensibility; it is not shipped.

Sources: [Rails I18n](https://guides.rubyonrails.org/i18n.html),
[Android locale resources](https://developer.android.com/guide/topics/resources/multilingual-support).

## Typography

Every app interface uses locally bundled [Martian Mono](https://evilmartians.com/products/martian-mono):
web, Android, AgentPrism, Mission Control, and Lookbook. No font CDN or system installation is needed.
The font supports Cyrillic, the ruble symbol, and weights 100–800.

`app/assets/stylesheets/typography.css` is the shared web layer. New layouts render `shared/typography`
after their own styles. Tailwind `font-sans`, `font-serif`, and `font-mono` point to the same family;
change size, weight, or spacing rather than introducing a second family.
Lookbook renders components in `component_preview` with shared styles/importmap, without navigation
or a user session dependency. Width is normalized to 100%; the upstream variable font defaults to 112.5%.

Android bundles TTF in `res/font`; the family/theme covers weights, toolbar, and Material text appearances.
WebView receives WOFF2 from Rails. System keyboards and OS interfaces follow device settings.

Version, archive, SHA-256, and license are in `vendor/fonts/martian-mono`.
Preserve the license and check glyphs, forms, and long text on narrow screens after updates.
Local Lookbook/Mission Control layouts and `hotwire_error.xml` add the font layer;
compare them with upstream when updating dependencies.

## Environments

Development and production use separate primary, queue, and cache databases.
Test uses primary and queue: the test adapter captures ordinary jobs, while observability tests use real
Solid Queue tables. Ordinary tests capture broadcasts; `bin/realtime-test` runs Go and a real browser.

- Local database parameters: `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD` in [database.yml](../config/database.yml).
  If you change Compose `POSTGRES_PORT`, set Rails `PGPORT` to match.
- App URL: [web.yml](../config/web.yml), with overrides in `config/web.local.yml` or
  `WEB_HOST`, `WEB_PROTOCOL`, `WEB_PORT`. `bin/rails` does not load `.env`; export variables before running it.
- Production requires database/SMTP settings from [deployment](deployment.md).
  `SECRET_KEY_BASE_DUMMY` is for asset builds only.

## Concurrency

`ConcurrencyConfig` owns thread and database-pool settings. Defaults live in the class;
production overrides are in [concurrency.yml](../config/concurrency.yml).
Puma, `bin/jobs`, `queue.yml`, and `database.yml` read it. Environment variable names remain conventional;
local YAML overrides go in `config/concurrency.local.yml`.

| ENV | Development / test | Production | Purpose |
| --- | --- | --- | --- |
| `RAILS_MAX_THREADS` | 3 | 5 | Threads per Puma process; AnyCable HTTP RPC shares this pool |
| `JOB_THREADS` | 3 | 3 | Concurrent jobs per worker |
| `JOB_CONCURRENCY` | 1 | 1 | Worker processes in fork mode |
| `DB_POOL` | 5 | 5 | Maximum primary/cache connections per Ruby process and database |
| `QUEUE_DB_POOL` | 10 | 5 | Maximum queue connections per Ruby process |
| `SOLID_QUEUE_SUPERVISOR_MODE` | `async` | `fork` | Worker, dispatcher, and scheduler topology |

Sizes must be positive integers. `DB_POOL` must cover the larger Puma/worker thread count.
`QUEUE_DB_POOL` must cover `max(RAILS_MAX_THREADS, JOB_THREADS + 2)` in fork mode;
async mode reserves seven internal threads instead of two. Invalid settings stop boot.
Async requires `JOB_CONCURRENCY=1`: [Solid Queue ignores process count in async mode](https://github.com/rails/solid_queue#fork-vs-async-mode).
Change mode through config/ENV so pool validation follows it. CLI `--mode` is for one-off diagnostics.

Local async mode avoids a reproduced pg/libpq crash after fork on macOS.
For the same reason, Rails tests use one process on macOS and two on Linux;
`PARALLEL_WORKERS` overrides test process count.

Pools belong to each process, not the whole service. Sum connections across web, workers, dispatcher,
scheduler, console, and containers. Reserve capacity for overlapping deployments and maintenance,
and compare the total with PostgreSQL `max_connections`.
These defaults are a starting point, not measured capacity. Before raising concurrency, measure p95,
CPU, memory, database wait, and queue age. `bin/jobs check` validates queue configuration.
Clustered Puma first requires changes to [metric collection](observability.md#metrics-and-alerts).

### Code rules

- Rails Executor runs HTTP/jobs with thread-scoped `Current`. Keep user data out of class variables,
  singleton state, and hidden Current memoization; declare explicit attributes.
- Pass user IDs to jobs. `RequestCorrelatedJob` carries `request_id`, scopes `job_id` log tags, and prevents
  `Current.session` leakage, including `perform_now` inside an HTTP request.
- If a custom thread is necessary, wrap app code in `Rails.application.executor.wrap`, pass context explicitly,
  bound waits, and collect errors through `Thread#value`. Threads do not replace durable jobs.
  Do not enable a fiber scheduler without reviewing isolation and library compatibility.
- Database indexes enforce uniqueness; Rails validation does not prevent races. Use atomic SQL or row locks
  for shared state. A process-local Mutex cannot protect other processes.
  Use Solid Queue `limits_concurrency` for resource limits and design idempotency separately.
- Do not mutate ENV, callbacks, class methods, or shared SDK configuration during a request/job.
  `rubocop-thread_safety` checks this in CI; ENV mutation checks cover `app/` and `lib/`.
  Static analysis does not prove race freedom.
- Isolator detects network calls inside development/test transactions. Test races using separate connections,
  barriers, and timeouts, without synchronization sleeps. See `test/lib/concurrency_test.rb`.

Rails 8.1 enables YJIT in production and disables it in development/test.
ZJIT, M:N, and Ractor are not additionally enabled; adoption needs a concrete workload,
gem compatibility, and measurements. The [Ruby 4.0 release](https://www.ruby-lang.org/en/news/2025/12/25/ruby-4-0-0-released/)
describes ZJIT and Ractor as evolving features. Survey speedups are not measurements of this app.
Sources: [Evil Martians concurrency](https://evilmartians.com/rails-startup-stack),
[Rails Executor](https://guides.rubyonrails.org/threading_and_code_execution.html),
[avoiding duplicates](https://evilmartians.com/chronicles/one-row-many-threads-how-to-avoid-database-duplicates-in-rails-applications).

## Authentication

Rails authentication generator provides User, Session, a signed HttpOnly cookie, CSRF, and sign-in rate limits.
Passwords require at least 12 characters; bcrypt sets the upper bound. Password reset revokes every session.
Controllers require authentication by default.

Action Policy enforces `authorize!`; `ApplicationController` detects missing checks.
`UserPolicy` permits only the user's own profile. Denial returns 403; an unknown rule raises.
Sign-in and password reset use their own password/token checks.
Admin, Mission Control, and AgentPrism require a session and `AdminPolicy#access?`.
Basic `/ops/health` and Bearer `/ops/metrics` remain separate machine contracts.
`User#admin` is granted explicitly; see [admin access](observability.md#admin).
Native receives the same permissions as web.

Rails 8.1.3.1 is incompatible with JSON 3 for cookies/tokens
([Rails issue](https://github.com/rails/rails/issues/58685)). Remove `json < 3` from Gemfile only after
upgrading Rails and verifying authentication flows.

## Essential gems

The Evil Martians essential capabilities are configured. Versions are in `Gemfile.lock`.

| Tool | Project usage |
| --- | --- |
| Anyway Config | Validated web, operations, LLM, and concurrency settings in `app/configs` |
| Action Policy | Policies and mandatory `authorize!` in application controllers |
| Active Delivery | `PasswordsDelivery.reset(user).deliver_later`; declare new events with `delivers` |
| Abstract Notifier | Included in Active Delivery; `ApplicationNotifier` and the `notifiers` queue |
| ViewComponent | UI components, Lookbook previews, and DOM tests |
| N+1 Control | Minitest `assert_perform_constant_number_of_queries` across growing data sets |
| Isolator | Rejects HTTP, email, or unsafe job enqueue inside development/test transactions |
| After Commit Everywhere | Explicit callbacks outside models, tested for nested transactions and rollback |
| Freezolite / Bootsnap | Frozen project string literals through `Bootsnap.enable_frozen_string_literal(app_only: true)` |
| Active Agent / RubyLLM | ERB prompts, explicit provider/model, Solid Queue generation, usage, and errors without implicit retries |
| Herb | HTML/ERB lint, formatter, and LSP; see [developer tools](development.md) |

[Abstract Notifier merged into Active Delivery](https://github.com/palkan/abstract_notifier), so its obsolete
gem is not installed. [Freezolite recommends Bootsnap](https://github.com/ruby-next/freezolite) for
Ruby 4.0.4+ and Bootsnap 1.24.4+; no separate hook is needed. `config/boot.rb` enables freezing;
create mutable strings with `+"text"`. `benchmark` is explicit for Sniffer because Ruby 4 no longer bundles it.

### Notifications and transactions

Call a delivery from an operation or controller. Mailers render email; notifiers build channel payloads.
`ApplicationNotifier` enqueues `NotifierDeliveryJob` after commit and preserves `request_id`.
Set each notifier's `self.driver` to an object implementing `call(payload)`; missing transport raises.
Push/SMS providers are not configured.

Jobs and email already use `enqueue_after_transaction_commit = true`.
For another post-transaction action, call `AfterCommitEverywhere.after_commit(without_tx: :raise) { ... }`
inside the operation. Move network effects outside transactions; do not disable Isolator.
Callbacks are not durable queues. Use jobs for required delivery; design an outbox separately when
atomicity across primary and queue databases is required.

### LLM

AI features use `ApplicationAgent` and text ERB prompts over RubyLLM.
Generation runs in Solid Queue after commit and preserves request/job IDs.
See [Active Agent](agents.md) for configuration, contracts, and feature integration.
