---
name: ui-figma
description: "Переносить утверждённый Figma-дизайн в StarterApp: токены, ViewComponent, Stimulus и Native UX."
metadata:
  upstream: sb-figma
  adapted-for: StarterApp
  version: "3"
---

# ui-figma

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Получи доступный исходный дизайн и размеры; если источника нет, не выдумывай его свойства.
- Сопоставь цвет, spacing и typography с существующими @theme tokens.
- Найди подходящий компонент до создания нового. Сохраняй семантические варианты API.
- Реализуй approved design в ERB/ViewComponent; interactivity — Stimulus; platform chrome — Kotlin.
- Добавь preview с настоящими состояниями, проверь responsive layout, labels, focus и touch.
- Укажи источник дизайна, конкретные соответствия токенов и проверенные отличия. Публикация в Figma требует запроса пользователя.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-figma.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-figma`.
