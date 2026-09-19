---
name: ui-health
description: "Проверять дизайн-токены, Tailwind и доступность интерфейса StarterApp."
metadata:
  upstream: sb-health
  adapted-for: StarterApp
  version: "3"
---

# ui-health

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Прочитай `app/assets/tailwind/application.css`, компоненты и их реальные вызовы.
- Найди повторяемые magic values, динамически конструируемые классы, недостающие семантические токены и противоречивые варианты.
- Проверь контраст, focus-visible, aria-состояния, labels, размер touch targets и длинные русские строки.
- Не удаляй токен, пока не проверены все templates, previews и JS.
- Используй `tailwind-best-practices` для исправлений, `ui-previews` для демонстрации состояний.
- Отчёт содержит конкретные пути, воспроизводимый пример и минимальную правку.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-health.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-health`.
