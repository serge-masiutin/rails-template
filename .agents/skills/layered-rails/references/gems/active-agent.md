# Active Agent: проверенный контракт

- Наследуй конкретный агент от ApplicationAgent; не переопределяй общую конфигурацию провайдера и job без отдельной необходимости.
- Задай PROMPT_VERSION строкой. Действие вызывает prompt; instructions.text.erb и шаблон действия лежат в app/views/<agent_name>.
- Вызов: именованный класс, действие с аргументами, затем generate_now или generate_later. Рабочие действия и prompt options смотри в ApplicationAgentTest::ProbeAgent.
- generate_later использует AgentGenerationJob и очередь agents после commit. Он не сохраняет продуктовый результат автоматически; прикладная job должна делать это явно.
- StarterappProvider адаптирует RubyLLM 2 tokens, finish_reason и tools. Проверяй installed SDK и тесты при обновлении; имя gem — activeagent из Gemfile.lock.
- Текущие тесты покрывают текст и простой tool loop. Structured output через Active Agent нельзя считать проверенным; действующий schema-путь — Llm.build_chat.with_schema с отдельной валидацией результата.
- SDK local_store сохраняет очищенные traces; capture_bodies, внешний endpoint и API-key телеметрии выключены. Сбой записи измеряется отдельно и не повторяет генерацию.

Источники поведения: [docs/agents.md](../../../../../docs/agents.md), [config/initializers/active_agent.rb](../../../../../config/initializers/active_agent.rb), [lib/active_agent/providers/starterapp_provider.rb](../../../../../lib/active_agent/providers/starterapp_provider.rb), [test/agents/application_agent_test.rb](../../../../../test/agents/application_agent_test.rb).
