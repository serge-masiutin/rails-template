# Active Agent contract

- Inherit ApplicationAgent; preserve shared provider/job configuration unless a concrete requirement changes it.
- Define string PROMPT_VERSION. Actions call prompt; instructions.text.erb and action templates live under app/views/<agent_name>.
- Call a named agent action with arguments, then generate_now or generate_later; copy actual options from ApplicationAgentTest::ProbeAgent.
- generate_later uses AgentGenerationJob on the agents queue after commit. It does not persist product results automatically; an application job must do that explicitly.
- StarterappProvider adapts RubyLLM 2 tokens, finish_reason and tools. Inspect installed SDKs/tests on upgrade; the gem is activeagent.
- Current tests cover text and a simple tool loop. Structured output through Active Agent is not established; the verified schema path is Llm.build_chat.with_schema with separate result validation.
- SDK local_store captures sanitized traces. Body capture, external telemetry endpoint and telemetry API key stay disabled. Record write failures without repeating generation.

Behavior sources: [docs/agents.md](../../../../../docs/agents.md), [config/initializers/active_agent.rb](../../../../../config/initializers/active_agent.rb), [lib/active_agent/providers/starterapp_provider.rb](../../../../../lib/active_agent/providers/starterapp_provider.rb), [test/agents/application_agent_test.rb](../../../../../test/agents/application_agent_test.rb).
