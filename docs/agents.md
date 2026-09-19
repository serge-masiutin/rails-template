# AI features: Active Agent and RubyLLM

`ApplicationAgent` defines shared generation settings. A named agent holds a prompt, accepts validated
context, and returns a response. A domain operation validates and explicitly saves the result.
Generation alone does not create a product feature or chat.

## Configure a provider

Set `LLM_PROVIDER`, `LLM_MODEL`, and `LLM_API_KEY` together through ENV or ignored
`config/llm.local.yml` fields `provider`, `model`, and `api_key`.
Supported providers: `openai`, `anthropic`, `gemini`. Restart web and jobs; SDK keys are set only at boot.
Kamal uses the same settings, with the key supplied as a secret.

The app boots without AI configuration; generation then fails before an HTTP request.
Models are checked against RubyLLM's local registry.
`LLM_REQUEST_TIMEOUT` defaults to 30 seconds and accepts 1–300. SDK/job retries are not enabled implicitly.

Versions are pinned in `Gemfile.lock`. `StarterappProvider` adapts Active Agent to RubyLLM 2:
it reads `tokens` and `finish_reason` instead of removed 1.x methods and passes tools via
`parameters_schema` and `provider_options`. The gem owns network requests and the tool loop.
Recheck this contract on upgrade and remove the local adapter once upstream is compatible.
RubyLLM 1.16 is unsuitable because of CVE-2026-67991.

## Add an agent

- Subclass `ApplicationAgent` in `app/agents` and declare a string `PROMPT_VERSION`.
  Bump it for meaningful prompt changes.
- Actions collect context and call `prompt`. Store text ERB in `app/views/<agent_name>/`:
  `instructions.text.erb` and `<action>.text.erb`. `instructions: true` requires the template and raises if missing.
- Treat user text as data, separate it from instructions, and validate output before writes, tools, or rendering.
  Never pass model text to `html_safe`.
- Explicitly call `<Agent>.<action>(...).generate_now` outside transactions.
  For long work, enqueue an application job with record IDs, reauthorize in the worker, generate, validate, and save.
- `generate_later` uses `AgentGenerationJob`, the `agents` queue, after-commit enqueue, and request ID propagation.
  Its return value exists in the worker; it does not automatically save results or update the UI.
  Prefer an explicit feature job when persistence is needed.
- Job arguments are stored in the queue database. Pass IDs, not secrets or whole documents.
  Pass the user explicitly; do not rely on `Current.user` in a worker.

For a short call without templates, use `Llm.build_chat`; `chat.ask(...)` performs the network request.
Do not mutate shared RubyLLM settings during a request or accept keys/models from params.

Structured output, tools, and streaming require feature-specific contracts and tests.
RubyLLM schemas differ from Active Agent `response_format`: this starter verifies text generation and a simple
tool loop, not JSON Schema passthrough. For schema calls, use `Llm.build_chat.with_schema(...)` and validate output.
Tools need explicit `max_tool_turns`, permissions, argument schemas, limits, and idempotency.

## Web and Android

Both clients render saved results with shared ERB/ViewComponent and Turbo Streams.
Use the existing private AnyCable subscription and stable targets. Provider keys stay on the server.
Escape partial model output too. Pending, denied, and failed states must survive page reload.

## AgentPrism

A trace records an agent run; a span records an operation such as an LLM call or tool call.
Keep the tool's terminology, including `trace`, `span`, `RAW`, and `Attributes`.

Open AgentPrism from `/admin` or `/ops/agents`. It requires an app session with `admin: true`;
see [admin access](observability.md#admin). Guests receive an HTML sign-in redirect or JSON 401;
non-admins receive 403. Health Basic credentials and metrics tokens do not grant viewer access.

After `ApplicationAgent` runs, AnyCable triggers a fresh fetch automatically.
The viewer shows the call tree, LLM/tools, duration, status, prompt version, request/job IDs, and reported usage.
Pages contain 20 traces. Direct `Llm.build_chat` calls are not instrumented by Active Agent.
The initial list is empty; no demo agents or paid calls run automatically.

- `AgentTrace::Document` converts SDK spans to an allowlisted AgentPrism contract.
  Prompts, responses, tool arguments/results, arbitrary events, and exception messages are removed.
  RAW shows the same sanitized contract. Errors expose their class; find the stack in correlated logs.
- Synchronous `local_store` runs after generation. External telemetry endpoints and API keys are disabled.
  Storage failure does not repeat a paid model call; it is reported through `Rails.error`,
  `starterapp_agent_trace_failures`, Grafana, and `StarterAppAgentTraceFailures`.
- `agent_traces` lives in primary PostgreSQL, with seven-day retention and hourly development/production cleanup.
  Queries immediately hide expired records. Manual cleanup: `mise exec -- bin/rails runner 'AgentTrace.prune'`.
- Each trace allows at most 256 spans and 32 levels. Invalid contracts are rejected and counted.
  Unknown usage stays unknown, cached input is separate, reasoning is not added to output twice,
  and cost is not calculated. SDK usage is not a complete bill for every tool-loop HTTP call.
  A completed span without SDK status is marked warning, not success.

The viewer is an isolated React bundle in `app/frontend/agents`. Its Operations layout loads
AnyCable/Turbo through importmap for update signals; React owns the viewer DOM.
Product screens remain Hotwire. Entry into the viewer uses a full page load.
AgentPrism UI/data/types are vendored from one commit with MIT license and SHA-256 in `source.json`,
because the published data package trails the current components.
Update all three together and run build/browser checks. Tailwind 4 styling is separate from upstream components.
`react-resizable-panels` stays on v3: upstream uses `PanelGroup`/`PanelResizeHandle`, removed in v4.
Lift the major-version constraint with a compatible AgentPrism update and desktop/mobile verification.
Lucide updates independently.

```sh
mise exec -- npm run check:agents
mise exec -- npm run build:agents
mise exec -- bin/rails test test/agents/application_agent_test.rb test/models/agent_trace test/controllers/operations
mise exec -- bin/rails test test/system/agent_prism_test.rb
```

`bin/setup` builds the viewer, `bin/dev` starts its watcher, and `bin/ci` checks types, provenance, and build.
Docker builds JS/CSS in a separate Node stage; Node/node_modules are absent from the runtime image.
Source: [Evil Martians AgentPrism](https://evilmartians.com/opensource/agent-prism).

## Diagnostics and validation

`agent.generated` includes agent/action, prompt version, provider/model, outcome, duration, and reported usage.
Request/job IDs use normal log tags. Logs exclude prompt/response text, API keys, and arbitrary exception
messages while retaining stacks. SDK traces stay local; body capture and `/rails/agents` are disabled.
See [observability](observability.md) for metrics and worker endpoints.

`test/agents/application_agent_test.rb` verifies ERB, conversation isolation, HTTP contracts, a simple tool loop,
usage, failures without retries, log privacy, commit/rollback, and job context. WebMock blocks external HTTP.
No production provider/model is selected and no paid requests are used by the starter's checks.
Transport tests do not measure output quality. Each product AI feature needs versioned typical, malformed,
and adversarial cases, explicit grading criteria, and regression checks after prompt/model changes.

Sources: [Evil Martians Active Agent article](https://evilmartians.com/chronicles/exploring-active-agent-or-can-we-build-ai-features-the-rails-way),
[RubyLLM adapter](https://docs.activeagents.ai/providers/ruby_llm),
[instrumentation](https://docs.activeagents.ai/framework/instrumentation).
