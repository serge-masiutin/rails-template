---
name: ui-ship
description: "Переносить выбранный UI-прототип StarterApp в продуктовые ViewComponent/ERB экраны."
metadata:
  upstream: sb-ship
  adapted-for: StarterApp
  version: "3"
---

# ui-ship

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Найди выбранный вариант и его критерии готовности; проверь существующие вызовы.
- Переиспользуй компонент, если контракт совпадает; иначе добавь маленький именованный компонент.
- Перенеси утверждённые токены, состояния и доступность, обнови реальные страницы атомарно.
- Сохрани preview как документацию публичного API.
- Удали неиспользуемый экспериментальный код в рамках изменения, сохраняя источник решения в PR.
- Проверь component/system tests и соответствующий Native сценарий; сообщи, что не запускалось.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-ship.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-ship`.
