---
name: ui-comparisons
description: "Сравнивать варианты, состояния и адаптивное поведение компонентов StarterApp в Lookbook."
metadata:
  upstream: sb-wrappers
  adapted-for: StarterApp
  version: "3"
---

# ui-comparisons

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Покажи два варианта с одинаковыми входными данными и размером viewport.
- Используй ViewComponent preview templates для state grids; не дублируй компонентную реализацию в preview.
- Группируй только значимые состояния: обычное, длинное содержимое, ошибка, disabled.
- Проверяй смысловую структуру DOM и фокус, а не только внешний вид.
- Для web/Native сравнения укажи, что рисует Rails, а что platform navigation.
- Результат — сравнимый preview и конкретное решение с проверенными ограничениями.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-wrappers.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-wrappers`.
