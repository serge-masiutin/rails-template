---
name: ui-explore
description: "Прототипировать новое оформление StarterApp в изолированных ViewComponent previews."
metadata:
  upstream: sb-explore
  adapted-for: StarterApp
  version: "3"
---

# ui-explore

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Зафиксируй пользовательскую задачу и существующие токены/компоненты.
- Прототип размещай в development-only preview; не добавляй неподтверждённый маршрут продукта.
- Сравни варианты на одинаковом содержимом, ширинах и состояниях.
- Отметь touch, keyboard, loading/error и Native layout consequences.
- Критерий переноса: выбранный API компонента, токены, доступность и проверяемый сценарий.
- Для переноса используй `ui-ship`; сохраняй только полезный preview, а не коллекцию заброшенных прототипов.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-explore.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-explore`.
