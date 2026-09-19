# Объект рядом с моделью

- Выделяй связную часть поведения в namespace владельца, когда у неё есть собственный контракт и независимая причина изменения.
- Передавай запись или проверенное значение явно. Не добавляй скрытые обращения к Current, request и глобальным SDK.
- Пример: AgentTrace::Document преобразует внешний trace, AgentTrace::Capture сохраняет результат; модель AgentTrace отвечает за хранение и retention.
- Не делай отдельный объект для простого доступа к одному атрибуту. Проверь контракт collaborator и один реальный путь через владельца.

Источники поведения: [app/models/agent_trace/document.rb](../../../../../app/models/agent_trace/document.rb), [app/models/agent_trace/capture.rb](../../../../../app/models/agent_trace/capture.rb).
