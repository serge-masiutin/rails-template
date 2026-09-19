---
name: rails-serialization
description: "Проектировать JSON-ответы StarterApp для Native-конфигураций и внешних интеграций."
metadata:
  upstream: alba-inertia
  adapted-for: StarterApp
  version: "3"
---

# rails-serialization

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Сначала выясни потребителя: для обычной страницы используй HTML, для Native path configuration — versioned JSON.
- Опиши обязательные поля, nullability, timezone, единицы и версии контракта.
- Сериализуй явно выбранные поля; не выдавай модель целиком через as_json.
- Для `public/configurations/*_v1.json` сохраняй settings/rules, regex patterns и платформенные properties.
- Не включай secrets, пользовательские записи и внутренние URL в публичную конфигурацию.
- Обратная совместимость со старыми мобильными клиентами обязательна: несовместимый формат публикуется как v2 с сохранением v1.
- Тестируй schema, потребительские случаи и отсутствие лишних полей; синхронизируй bundled JSON командой `bin/native sync`.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/alba-inertia.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/alba-inertia`.
