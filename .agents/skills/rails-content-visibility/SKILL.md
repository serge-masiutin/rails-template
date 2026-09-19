---
name: rails-content-visibility
description: "Готовить публичный контент Rails StarterApp к индексированию и чтению агентами без раскрытия приватных данных."
metadata:
  upstream: llms-visibility
  adapted-for: StarterApp
  version: "3"
---

# rails-content-visibility

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Сначала установи, какие страницы действительно публичные; проверь authentication и права.
- Публичная HTML-страница имеет корректный title, headings, текст и canonical URL.
- Markdown/JSON-представление добавляй для конкретного потребителя с теми же правилами доступа.
- robots.txt и llms.txt не заменяют авторизацию. Не индексируй кабинет, session, password reset и пользовательские записи.
- При content negotiation укажи корректный Content-Type и Vary; проверь поведение кэша.
- Проверяй доступ гостя и пользователя, отсутствие утечки секретов и соответствие HTML/Markdown содержимого.
- Результат — доступный публичный ресурс и тесты границы, а не обещание улучшенного ранжирования.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/llms-visibility/SKILL.md`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/llms-visibility`.
