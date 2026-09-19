---
name: hotwire-rails-architecture
description: "Выбирать архитектуру новой функции StarterApp сразу для веба и Android на Rails и Hotwire."
metadata:
  upstream: inertia-rails-architecture
  adapted-for: StarterApp
  version: "4"
---

# hotwire-rails-architecture

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Прочитай `docs/architecture.md` и `docs/native.md`; проверь routes, модели, layouts и существующие компоненты.
- Сервер владеет данными, авторизацией, маршрутизацией и валидацией. Общее представление — ERB/ViewComponent.
- Turbo Drive обслуживает переходы между страницами; Frame — независимую область; Stream — несколько адресуемых изменений DOM.
- Обновления между клиентами идут через AnyCable/Turbo Streams. Проверяй доступ к потоку в канале; текущий приватный поток — `UserUpdatesChannel`. Ограничения истории и отзыва сессий — `docs/realtime.md`.
- Сохраняй единственную регистрацию `turbo-cable-stream-source` через `@anycable/turbo-stream`; не подключай параллельно JS `@hotwired/turbo-rails`.
- Stimulus используй для локального взаимодействия, Native Bridge — для функций устройства.
- Сначала опиши один пользовательский путь и его HTTP-контракт, затем реализуй его во всех затронутых клиентах.
- Для формы открой `hotwire-rails-forms`; для нативной функции — `hotwire-native-components`; для тестов — `hotwire-rails-testing`.
- Критерий готовности: общий сценарий работает в обычном HTML, с Turbo и в нативной навигации; ограничения проверок указаны явно.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-architecture.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-architecture`.
