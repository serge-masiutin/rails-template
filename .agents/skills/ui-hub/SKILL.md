---
name: ui-hub
description: "Выбирать рабочий процесс проектирования и проверки UI StarterApp в ViewComponent/Lookbook."
metadata:
  upstream: sb-hub
  adapted-for: StarterApp
  version: "3"
---

# ui-hub

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Исследуй routes, app/views, app/components, previews и дизайн-токены.
- Для нового UI начни с `ui-inventory`; для прототипа — `ui-explore`; для утверждённого Figma — `ui-figma`.
- Каталог компонентов — Lookbook `/lookbook` только в development; страницы продукта проверяй в Rails.
- Последовательность для новой UI-системы: inventory → tokens/health → previews → system tests → audit.
- Для каждого шага дай конкретные найденные файлы и следующий необходимый артефакт. Не создавай процессные документы без нужды.
- Критерий готовности: компонент используется, отражён в каталоге и проверен в вебе и соответствующих Native сценариях.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-hub.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-hub`.
