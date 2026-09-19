---
name: ui-flows
description: "Картировать маршруты и пользовательские переходы StarterApp между вебом и Android."
metadata:
  upstream: sb-flows
  adapted-for: StarterApp
  version: "3"
---

# ui-flows

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Источник маршрутов — config/routes.rb и bin/rails routes; переходов — links/forms/redirects и Native path configurations.
- Отметь гостевые/защищённые экраны, GET-переходы, мутации, modal и возврат после входа.
- Проверь, что web navigation не дублирует нативную панель, а account/logout доступны обоим клиентам.
- Для спорного потока сделай небольшую Mermaid-схему с HTTP-статусами и auth boundary.
- Проверь Back/Forward, dismiss modal, невалидную форму и истёкшую сессию.
- Не придумывай продуктовые экраны: явно отдели существующий маршрут от предложения.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-flows.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-flows`.
