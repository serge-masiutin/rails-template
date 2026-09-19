# StarterApp: agent instructions

## Start here

- This is a Rails/Hotwire and Android template. Run `bin/configure` before the first `bin/setup`; see `docs/template.md`. Preserve the identity of an already configured application.
- Write repository content in English: documentation, instructions, skills, comments, CLI messages and UI copy. Reply to the user in their preferred language. Preserve upstream sources and licenses verbatim.
- Read related code, contracts, versions, tests and configuration before planning a local change.
- Sources of truth: manifests and lockfiles, `config/routes.rb`, database schemas, tests, native build files and `docs/architecture.md`.
- Shared screens serve both the web and Android. Assess changes for both clients.
- Configure Git identity, SSH and GitHub CLI only for this repository. Preserve the owner's account; never change global settings or switch the global CLI account for this project.

## Project skills

`.agents/skills/` contains 30 Evil Martians adaptations and the project skill `clear-writing`.
Read the relevant `SKILL.md` and only the references needed for the task.
Provenance and review cases: `docs/agent-skills.md`.

| Task | Read |
| --- | --- |
| Features, architecture, refactoring | `layered-rails`, `hotwire-rails-architecture` |
| Controllers, forms, pages | `hotwire-rails-controllers`, `hotwire-rails-forms`, `hotwire-rails-pages` |
| Stimulus and components | `hotwire-stimulus-components`, `hotwire-ui-components`, `tailwind-best-practices` |
| Android and bridge contracts | `hotwire-native-components`, `hotwire-bridge-contracts`, `rails-serialization` |
| Design and component catalog | `ui-hub`, then the relevant `ui-*` skill |
| Tests | `hotwire-rails-testing` |
| Setup, dependencies, CI/CD | `hotwire-rails-setup`, `dependency-supply-chain` |
| README and documentation | `good-readme`, `clear-writing` |
| UI copy, email, explanations | `clear-writing` |
| Handoff after sustained work | `intent-log` |
| Skill maintenance | `agent-skills-maintenance` |

Names refer to `.agents/skills/<name>/SKILL.md`. Working skills describe this project's
Rails/Hotwire/Native workflows. Originals in `vendor/agent-skills/evilmartians` are comparison
material; do not execute their scripts automatically. When changing a skill, increment
`metadata.version`, review affected cases and run `bin/skills check`.

## Documentation and writing

- Update affected documentation, examples, rules and skills with the code. Verify them against actual behavior before finishing.
- Update an existing document first. Create a new one only for a distinct recurring reader task and link it from README or the relevant guide.
- Keep one authoritative document per topic. Remove outdated instructions and duplication, fixing incoming links. Preserve history only when it explains a current decision or a supported contract.
- Keep README to purpose, setup, checks and navigation. Put subsystem details in their guide and one-off results in the PR or a short dated handoff.
- Apply the reader-focused principles in `clear-writing`: lead with the useful result, use concrete facts and actions, explain unfamiliar ideas with relevant examples, and organize by the reader's task.
- Preserve product names, API fields and precise technical terms. Use AgentPrism, trace/span and Solid Queue terminology consistently across UI and docs.
- Remove repetition and unsupported claims while retaining conditions, limits, units and causal links. Neither minimum length nor an editing score is the goal.

## Architecture and contracts

- Use Rails, PostgreSQL, Hotwire, importmap, Tailwind and ViewComponent; read exact versions from manifests and lockfiles.
- Put domain rules in models and complex operations next to the relevant model in its namespace. Keep controllers and jobs thin. ERB/ViewComponent renders HTML; Stimulus handles local interaction.
- Authorize with Action Policy and `authorize!`; send application notifications through Active Delivery. See `docs/architecture.md`.
- Keep Isolator enabled. Test collection queries for N+1 behavior with growing datasets.
- Configure thread counts and database pools through `ConcurrencyConfig`. Preserve Current/log isolation, unique indexes and `rubocop-thread_safety`; test races with real threads, barriers and timeouts.
- Use `ApplicationAgent` for AI actions and `Llm.build_chat` for direct calls without templates. Make model selection, retries and content capture explicit.
- Separate commands and queries. Make network calls, writes and publishing explicit.
- Validate required data at boundaries, then access it directly with `params.expect`, `fetch` and explicit types or DTOs.
- Fail loudly on contract violations. Do not add silent fallbacks, broad rescue clauses, fake data, unrequested retries or unnecessary dependencies.
- Preserve behavior unless the task changes it. Update all consumers of a changed contract together.
- Do not add empty layers, generic services/utils containers, multi-agent orchestration or caching without demonstrated need.

## AI features

- Use `ApplicationAgent`, `PROMPT_VERSION` and text ERB templates; see `docs/agents.md`.
- Run long generations in jobs after commit. Pass record IDs, recheck access, validate and persist results explicitly, then deliver HTML through private Turbo Streams to web and Android.
- Never log prompts, responses, tool bodies or keys. Record bounded metrics, versions and request/job IDs; keep SDK body capture disabled.
- AgentPrism lives at `/ops/agents`. Preserve the `AgentTrace::Document` allowlist, retention, administrator access and write-error metric. Node builds only this separate viewer.
- New AI features need HTTP boundary tests and a versioned quality evaluation set. Recheck quality when prompts, models, schemas or tools change.

## Interface language

- Publish only `en` initially. Put first-party page, form, error, notification, email and preview text in `config/locales/en.yml`; use `t`/`I18n.t`, `l` for dates and `count` for plurals.
- Do not concatenate translated sentences. Use named interpolation. Never apply `html_safe` to user input; HTML is allowed only in owned `_html` keys.
- Resolve locale through the explicit allowlist in `Localization`, scope it with `I18n.with_locale` and preserve it in links. Do not assign global locale in controllers or hide missing translations with fallbacks.
- Pass the required dictionary from Rails to JS with a checked contract. Android uses `res/values/strings.xml` and the published locale list. See `docs/architecture.md#interface-languages` for new locales, vendor limitations and RTL checks.

## Hotwire and Native

- Use the local Martian Mono font throughout, including code blocks and admin tools. New layouts include `shared/typography`; see `docs/architecture.md#typography` and Android `res/font`.
- HTML is shared by web and Android. Forms use Rails, cookies and CSRF. Successful mutations return 303, validation failures 422 and malformed parameters 400.
- Frame responses include the matching frame ID. Keep stream targets stable and clean up Stimulus subscriptions on disconnect.
- AnyCable serves WebSockets. Check stream access inside channels, preserve session revocation and test delivery/recovery with `bin/realtime-test`; see `docs/realtime.md`.
- Use authorized Turbo Stream signals after commit for admin updates. Fetch fresh data only on relevant events, reconnect or visibility return; coalesce events and preserve input/selection. Do not add periodic browser polling.
- Native User-Agent changes presentation, never permissions. Check authentication and authorization independently.
- Public Native contracts live in `public/configurations/*_v1.json`; synchronize bundled copies with `bin/native sync`.
- Preserve contracts used by released clients; version incompatible changes. Update bridge JSON, JS, Kotlin and tests together. Release clients use HTTPS.
- Use Active Storage and imgproxy through `.variant(...)`; see `docs/images.md` for access and validation.

## Logs and observability

- Use Yabeda for metrics, `Rails.logger` for structured events and `Rails.error` for error reporting. See `docs/observability.md`.
- Ordinary logs go to JSON files/stdout and Alloy/Loki, never application tables. `AgentTrace` is separate sanitized AI execution data with explicit retention.
- Keep local file and container log rotation bounded. Suppress only successful health/metrics request summaries; preserve authentication failures, errors and warnings.
- Inherit jobs from `ApplicationJob`; retain request/job correlation. Never log request parameters, job arguments, secrets, PII or arbitrary user text.
- Keep metric and Loki label cardinality bounded. IDs and arbitrary URLs do not belong in labels.
- Put operational UI under the shared `/admin` navigation with `Admin::BaseController`, `AdminPolicy` and no-store. Machine health/metrics retain separate Basic/Bearer contracts.
- Clear sensitive panels and unsubscribe when access is revoked. Show connection failures. `bin/dev` starts local monitoring; production access and alert delivery require explicit deployment configuration.
- Queue/monitoring changes must cover failures, correlation, guest/user/admin access and role revocation. Update dashboards and alerts with their metrics.

## Checks and completion

- Test observable behavior and critical failures. Start with the narrow relevant test, then run `bin/ci`.
- Choose test coverage by risk and contract, using the lowest sufficient level. Prefer existing tests; avoid testing dependency internals, duplicate paths or cosmetic details. Keep security boundaries and known integration regressions. The decision guide is in `docs/testing.md`.
- See `docs/testing.md` for TestProf and HTTP/WS load checks. Do not run the load harness alongside other tests or hide flaky failures with automatic retries.
- Main checks: `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, `bin/erb-check`, `bin/rails zeitwerk:check`, `bin/skills check`, `bin/native check`.
- Use pinned tools through mise. Editor/LSP/Lefthook instructions: `docs/development.md`. Ruby examples in README/docs are checked by rubocop-md. Format ERB explicitly and inspect the diff and affected screen.
- Native builds: `docs/native.md`; CI/CD: `docs/deployment.md`.
- Report changes, executed checks and limitations. Do not claim success without relevant evidence. For sustained work, leave a concise entry in `docs/intent-log.md`.
- Keep secrets, keys, private documents, PII and private reasoning out of code, logs and skills.
- Keep changes local, reversible and reviewable, without dead code, placeholders or incidental formatting.
