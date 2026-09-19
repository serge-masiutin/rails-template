---
name: agent-skills-maintenance
description: "Адаптировать, проверять и обновлять локальные skills StarterApp с сохранением источников Evil Martians."
metadata:
  upstream: skills-visibility
  adapted-for: StarterApp
  version: "5"
---

# agent-skills-maintenance

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Реестр — config/agent_skills.json: skills хранит адаптации Evil Martians с SHA-256, project_skills — собственные skills. Оригиналы — vendor/agent-skills/evilmartians.
- Проверяй не только SKILL.md, но и вызываемые references, examples, workflows и scripts. Сверяй примеры с lockfiles, кодом и тестами; переписывай устаревшие API под наш стек. Проверка frontmatter не проверяет смысл вложенных инструкций.
- Рабочие инструкции находятся в .agents/skills и ориентируются на фактический стек StarterApp.
- При обновлении сравни upstream и локальную версию; переноси полезное намерение, а не старые React/Inertia API.
- Каждый skill имеет узкий trigger, явные входы, пути, проверяемый результат и контекст применения.
- Новый skill добавляй для отдельной повторяющейся задачи; при пересечении обновляй существующий. Удаляя skill, обнови реестр, маршрутизацию в AGENTS.md и ссылки.
- Не переноси секреты и полные пользовательские документы в инструкции.
- Запусти `bin/skills check`, проверь ссылки и сценарии из docs/agent-skills.md; запиши ограничения проверки.
- Обновление upstream не перезаписывает локальные инструкции автоматически.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/skills-visibility/SKILL.md`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/skills-visibility`.
