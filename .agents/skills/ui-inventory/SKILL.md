---
name: ui-inventory
description: "Находить компоненты, дубли разметки и реальные места использования UI StarterApp."
metadata:
  upstream: sb-inventory
  adapted-for: StarterApp
  version: "3"
---

# ui-inventory

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Источники: app/components, app/views, app/javascript/controllers, test/components/previews.
- Для каждого кандидата найди render-вызовы и Stimulus bindings; наличие файла не доказывает использование.
- Отличай компонент системы дизайна, однократный экран, mailer и ошибочную дублированную разметку.
- Сопоставь варианты компонента с вызовами и preview-методами.
- Представь краткую таблицу: компонент, места использования, состояния, preview/test gaps.
- Предлагай минимальное объединение по устойчивому смыслу, а не по похожим CSS-классам.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-inventory.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-inventory`.
