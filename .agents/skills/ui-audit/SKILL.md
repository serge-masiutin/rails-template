---
name: ui-audit
description: "Проводить ревью каталога и продуктового UI StarterApp на drift, неиспользуемые компоненты и пропущенные состояния."
metadata:
  upstream: sb-audit
  adapted-for: StarterApp
  version: "3"
---

# ui-audit

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Сопоставь реальные render-вызовы с previews и тестами.
- Найди устаревшие варианты, неиспользуемые компоненты и расхождение preview с production-разметкой.
- Проверь токены через `ui-health`, переходы через `ui-flows`.
- Раздели подтверждённые дефекты и предложения; для каждого дефекта покажи сценарий и путь.
- Исправления держи локальными, без глобальной стилистической переписи.
- После изменения обнови preview, тест и связанный контракт в одной правке.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-audit.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-audit`.
