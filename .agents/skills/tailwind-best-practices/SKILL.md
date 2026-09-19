---
name: tailwind-best-practices
description: "Писать и проверять Tailwind 4 в ERB/ViewComponent StarterApp с общими дизайн-токенами."
metadata:
  upstream: tailwind-best-practices
  adapted-for: StarterApp
  version: "4"
---

# tailwind-best-practices

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Источник версии — Gemfile.lock; сборка — tailwindcss-rails, стили — app/assets/tailwind/application.css.
- Все семейства Tailwind используют `--font-ui` из `app/assets/stylesheets/typography.css`: только локальный Martian Mono. Новый layout подключает `shared/typography`; проверяй кириллицу и длинный текст на узком экране.
- Объявляй семантические цвета в @theme, используй существующую шкалу spacing/типографики.
- Повторяемый UI выделяй в ViewComponent; общие компоненты принимают фиксированные варианты.
- Держи class lists короткими: layout → spacing → typography → color → interaction; используй px/py вместо дублирующих направлений.
- Классы должны быть полными литералами, включая variants в Ruby maps. Избегай динамической интерполяции имён.
- Не извлекай компоненты через @apply: шаблон и контракт принадлежат ViewComponent.
- Проверяй focus-visible, контраст, mobile safe area, длинный текст и production `assets:precompile`.
- Пример: `VARIANTS.fetch(variant)` возвращает фиксированный набор классов, а не произвольный className.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/tailwind-best-practices/SKILL.md`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/tailwind-best-practices`.
