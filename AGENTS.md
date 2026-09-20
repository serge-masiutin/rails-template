# StarterApp: agent contract

## Working with the project

- This is a Rails/Hotwire and Android template. Run `bin/configure` before the first `bin/setup`; see [template setup](docs/template.md). Preserve the identity of an already configured app.
- Write repository content in English: code, technical messages, comments, documentation, and skills. Reply in the user's preferred language. Preserve third-party licenses and notices.
- Read related code, callers, configuration, and tests before planning a local change. Use manifests, lockfiles, routes, schemas, and code as sources of truth. Run pinned tools through `mise exec --`.
- Preserve behavior outside the task. Update all consumers of a changed contract together; keep changes local and reversible.
- Configure Git identity, SSH, and GitHub credentials only for this repository. Preserve the owner's account and other projects; never change global settings for this project.

## Code and data

- Rails renders shared HTML for web and Android. Use PostgreSQL, Hotwire, importmap, Tailwind, and ViewComponent; Stimulus owns local interactions.
- Put behavior and simple queries in methods of the model that owns the data. Extract a class for an independent responsibility, not for every action. Integrations and diagnostics belong in `lib`; controllers and jobs accept inputs and delegate work.
- Make code clear through names and structure. Comments explain non-obvious reasons, invariants, and constraints rather than restating code.
- Authorize through Action Policy and `authorize!`. Validate external inputs at boundaries; read required fields through `params.expect`, `fetch`, and explicit contracts.
- Separate reads from mutations. Do not hide errors with empty values, broad rescue clauses, implicit retries, or invented data.
- Preserve atomicity. Run external effects after commit and keep Isolator enabled. Jobs inherit from `ApplicationJob`; notifications use Active Delivery.
- Configure threads and database pools through `ConcurrencyConfig`. Preserve Current/log isolation and enforce uniqueness and concurrent invariants in the database.
- Reuse ViewComponents, design tokens, and Lookbook previews. New layouts include `shared/typography`; all interfaces use local Martian Mono.
- Put owned UI and email copy in `config/locales/en.yml`; use `t`/`I18n.t`, `l`, and `count`. Scope locale through `I18n.with_locale`. Do not mark user text `html_safe` or hide missing translations with fallbacks.
- Return 303 after successful mutations, 422 for invalid forms, and 400 for malformed parameters. Preserve frame IDs, stream targets, and subscription cleanup on Stimulus disconnect.
- Native User-Agent affects presentation, never permissions. Change bridge JSON, JS, Kotlin, and tests together; preserve published Native contracts.
- Use `ApplicationAgent`, `PROMPT_VERSION`, and ERB prompts for AI; use `Llm.build_chat` for direct calls. Make model selection, queueing, and retries explicit.
- Never log secrets, PII, private documents, prompts, or model responses. Use Rails.logger, Rails.error, and Yabeda with bounded metric labels.

## Task context

Read the relevant guide and `.agents/skills/<name>/SKILL.md` before the corresponding work.
Load only the nested references needed for the task.

| Task | Guide | Skills |
| --- | --- | --- |
| Architecture and Rails | [Architecture](docs/architecture.md) | `layered-rails`, `hotwire-rails-architecture` |
| Controllers, forms, pages | [Hotwire](docs/hotwire.md) | `hotwire-rails-controllers`, `hotwire-rails-forms`, `hotwire-rails-pages` |
| Components and Tailwind | [Development](docs/development.md) | `hotwire-ui-components`, `tailwind-best-practices` |
| Android, bridge, JSON | [Android](docs/native.md) | `hotwire-contracts`, `rails-serialization` |
| Catalog diagnosis and next steps | [Development](docs/development.md) | `lookbook-hub` |
| Lookbook installation and configuration | [Development](docs/development.md) | `lookbook-setup` |
| Components, consumers, and preview coverage | — | `lookbook-inventory` |
| Colors, tokens, and style consistency | — | `lookbook-health` |
| Routes and user journeys | — | `lookbook-flows` |
| Component and page previews | — | `lookbook-previews` |
| New or redesigned component prototypes | — | `lookbook-explore` |
| Shipping an accepted prototype | — | `lookbook-ship` |
| Comparing variants, states, and reports | — | `lookbook-comparisons` |
| Figma designs and tokens | — | `lookbook-figma` |
| Catalog maintenance audit | — | `lookbook-audit` |
| WebSockets and images | [AnyCable](docs/realtime.md), [images](docs/images.md) | `hotwire-rails-pages` |
| AI, queues, and monitoring | [AI](docs/agents.md), [observability](docs/observability.md) | `layered-rails` |
| Setup, dependencies, and CI/CD | [Development](docs/development.md), [deployment](docs/deployment.md) | `hotwire-rails-setup` |
| Testing | [Testing](docs/testing.md) | `hotwire-rails-testing` |
| Slow Rails boot | [Architecture](docs/architecture.md) | `rails-boot-profiling` |
| README | [README](README.md) | `good-readme`, `clear-writing` |
| Copy, documentation, and user responses | — | `clear-writing` |
| Public websites or docs for LLMs | — | `llms-visibility` |
| Publishing and distributing skills | — | `skills-visibility` |
| Publishing an npm package | — | `secure-npm-package` |
| Work log requested by the user | — | `intent-log` |

## Checks and completion

- Test changed behavior at the simplest sufficient level. Extend existing tests of public contracts and critical failures.
- Start with focused checks. Run `bin/ci` for code, configuration, and integration changes. Check links, commands, and relevant linters for documentation changes.
- Verify transport changes with `bin/realtime-test` or `bin/image-test`. Run `bin/native check` and the relevant [Android checks](docs/native.md). Run load tests separately from other suites.
- Recheck AI quality on the feature's evaluation cases when changing prompts, models, schemas, or tools.
- Report changes, executed checks, and material limitations. Do not claim unverified behavior works.

## Documentation

- Describe current behavior, contracts, and working commands. Clearly separate planned features from implemented ones.
- Keep one main guide per topic; update it with the code and repair incoming links.
- Put one-off execution results, work history, and change discussions in the response or PR, not permanent instructions.
