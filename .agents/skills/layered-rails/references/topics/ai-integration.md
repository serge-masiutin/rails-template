# AI-функция в StarterApp

- Отталкивайся от конкретного пользовательского результата и проверяемого контракта. Зафиксируй входы, доступ, допустимые эффекты, формат ответа и критерии качества.
- Используй ApplicationAgent, PROMPT_VERSION и текстовые ERB. Прикладная job получает ID, загружает контекст, повторно проверяет доступ, вызывает generate_now вне транзакции и явно сохраняет проверенный результат.
- Пользовательский текст отделяй от инструкций. Ответ модели не является командой, HTML или разрешением вызвать tool. Проверяй схему и права до побочных эффектов.
- Сохранённый результат показывай через общий ERB/ViewComponent и приватный AnyCable/Turbo Stream. Состояния ожидания и ошибки должны переживать reload и возвращение Android из фона.
- Llm.build_chat подходит прямому вызову без шаблона и текущему schema API. Он не создаёт Active Agent traces; основной путь AI-функций проходит через ApplicationAgent.
- Ошибка не заменяется обрезанным исходником, пустым текстом или фиктивной категорией. Retries, tool budgets и таймауты задаются явно на границе.
- Диагностика: agent.generated, Yabeda, request/job ID и очищенные AgentPrism traces. Не сохраняй prompt, output и tool bodies в журналах.
- Перед усложнением retrieval, orchestration или кэша сравни простой baseline с версионируемыми evals. Проверяй типичные, неоднозначные и adversarial входы.

Источники поведения: [docs/agents.md](../../../../../docs/agents.md), [app/agents/application_agent.rb](../../../../../app/agents/application_agent.rb), [test/agents/application_agent_test.rb](../../../../../test/agents/application_agent_test.rb).
