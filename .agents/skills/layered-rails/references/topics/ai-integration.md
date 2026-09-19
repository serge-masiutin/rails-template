# AI features

- Start from a user outcome and testable contract: inputs, access, allowed effects, output format and quality criteria.
- Use ApplicationAgent, PROMPT_VERSION and text ERB. An application job takes IDs, reloads context, rechecks access, calls generate_now outside a transaction and explicitly persists validated results.
- Separate user content from instructions. Model output is not a command, trusted HTML or tool permission; validate schemas and access before side effects.
- Render persisted results with shared ERB/ViewComponent and private AnyCable/Turbo Streams. Pending/error states must survive reload and Android background return.
- Llm.build_chat handles direct calls without templates and the current schema API. It does not create Active Agent traces; ApplicationAgent is the normal feature path.
- Never replace failures with truncated input, empty output or fabricated categories. Configure retries, tool budgets and timeouts at the boundary.
- Diagnose with agent.generated, Yabeda, request/job IDs and sanitized AgentPrism traces. Never store prompts, outputs or tool bodies in logs.
- Compare a simple baseline using versioned evals before adding retrieval, orchestration or caching. Include typical, ambiguous and adversarial inputs.

Behavior sources: [docs/agents.md](../../../../../docs/agents.md), [app/agents/application_agent.rb](../../../../../app/agents/application_agent.rb), [test/agents/application_agent_test.rb](../../../../../test/agents/application_agent_test.rb).
