---
name: ui-catalog-setup
description: "Поддерживать каталог компонентов StarterApp на Lookbook и ViewComponent previews."
metadata:
  upstream: sb-setup
  adapted-for: StarterApp
  version: "4"
---

# ui-catalog-setup

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Проверь gem lookbook, development-only mount и view_component.previews.paths.
- Превью живут в test/components/previews и используют детерминированные входы без production DB и сетевых вызовов.
- Используй `component_preview` layout с настоящей Tailwind сборкой, `shared/typography` (Martian Mono), importmap и Stimulus. Он задаётся через `config.view_component.previews.default_layout` в development и не зависит от сессии пользователя.
- Организуй каталог по компонентам и смысловым состояниям: обычное, длинный текст, ошибка, disabled.
- Проверь `/lookbook` в development и отсутствие маршрута в production.
- После настройки проверь рендер хотя бы одного preview и компонентный тест; зафиксируй результат в docs/intent-log.md.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-setup.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-setup`.
