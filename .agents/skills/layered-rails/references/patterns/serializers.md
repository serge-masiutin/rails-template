# Контракты JSON

- Сначала установи потребителя: обычный экран получает HTML, Native path configuration — versioned JSON, AgentPrism — закрытый очищенный контракт.
- Выбирай поля явно и фиксируй version, nullability, типы, единицы и timezone. Не выдавай Active Record модель целиком.
- Валидируй внешний SDK input до преобразования; обязательные поля читай через fetch. Неизвестные статусы, повреждённые даты и превышение лимита отклоняются.
- Backend и decoder потребителя меняются атомарно. Публичная конфигурация Android сохраняет совместимость с уже установленными клиентами.
- Проверь лишние чувствительные поля, malformed input, пагинацию, размер и права.

Источники поведения: [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb), [app/frontend/agents/trace-page.ts](../../../../../app/frontend/agents/trace-page.ts), [test/models/agent_trace/document_test.rb](../../../../../test/models/agent_trace/document_test.rb), [public/configurations/android_v1.json](../../../../../public/configurations/android_v1.json).
