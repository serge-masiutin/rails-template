# Явная сериализация без нового DSL

- Для продуктового интерфейса возвращай HTML. JSON нужен Native configuration, служебному экрану или конкретному API-потребителю.
- Составь Hash из разрешённых полей; модель целиком через as_json не выдавай. Зафиксируй типы, nullability, единицы времени и версию.
- Рабочий пример — AgentTrace::Document и decodeTracePage: Ruby выдаёт контракт, TypeScript валидирует его на входе.
- Для небольшого контракта достаточно штатных Ruby/JSON и отдельного объекта преобразования. Новый serializer gem оправдан только повторяющейся сложностью текущего контракта.
- Проверь лишние/отсутствующие поля, malformed values, права, объём коллекции и совместимость потребителя.

Источники поведения: [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb), [app/frontend/agents/trace-page.ts](../../../../../app/frontend/agents/trace-page.ts), [docs/hotwire.md](../../../../../docs/hotwire.md).
