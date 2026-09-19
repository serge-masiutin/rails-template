---
name: layered-rails
description: "Design and review Rails models, operations, controllers, jobs, components and integrations."
metadata:
  upstream: layered-rails
  adapted-for: StarterApp
  version: "11"
---

# layered-rails

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `docs/architecture.md`, affected calls, models and tests first.
- Operational UI belongs in `/admin` with session checks, `AdminPolicy`, no-store and shared navigation through `Admin::BaseController`. Administrator status does not replace product policies. Keep machine Basic health and Bearer metrics separate; see `docs/observability.md`.
- AI traces flow through `AgentTrace::Document` into PostgreSQL and private `/ops/agents`. Preserve the field allowlist, absent bodies/secrets, seven-day retention and observable write failures. Ordinary logs use Alloy/Loki, not this table. React AgentPrism is an isolated operations view; product HTML remains shared by Hotwire/Android.
- Controllers accept HTTP, validate and delegate. Keep domain rules in models and named operations in their namespace; use a model/action name such as `Order::Checkout` when that domain exists, not a generic `app/services` container.
- Jobs coordinate work. Keep requests, cookies, Current and Turbo out of domain interfaces.
- Keep simple CRUD conventional. Reuse Action Policy; introduce form/query objects only for an identified responsibility.
- Send notifications through explicit Active Delivery `delivers`, mailer/notifier lines and jobs after commit; see `references/gems/active-delivery.md`.
- Do not perform network actions inside transactions. Jobs defer until commit; other callbacks use `AfterCommitEverywhere.after_commit(without_tx: :raise)`. Never suppress Isolator.
- Protect concurrent writes with unique indexes, atomic SQL or database locks. A Mutex cannot protect another process; job idempotency and `limits_concurrency` solve different problems.
- Current holds only declared context attributes; jobs receive users explicitly. Never mutate ENV, callbacks, classes or shared SDK configuration per request. Keep thread-safety lint checks.
- Use `ApplicationAgent`, `PROMPT_VERSION`, text ERB, jobs after commit and explicit persistence of validated AI results. See `docs/agents.md`; use `Llm.build_chat` for a direct call without a template.
- Deliver escaped results through private Turbo Streams to web/Android. Pass IDs to jobs, recheck access and never treat model output as trusted instructions.
- ViewComponent owns HTML, Stimulus browser interaction and Kotlin device capabilities.
- Read the relevant `references/` pattern, `workflows/review.md` for review or `workflows/plan.md` for planning. Working references/examples/workflows point to current implementations; originals stay in vendor.
- Test observable behavior at the relevant layer. Reviews identify the concrete call, violation and smallest correction.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/layered-rails.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/layered-rails`.
