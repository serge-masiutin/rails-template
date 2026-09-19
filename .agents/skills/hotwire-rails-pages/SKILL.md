---
name: hotwire-rails-pages
description: "Создавать страницы, навигацию, фильтры и обновления StarterApp через ERB, Turbo и Stimulus."
metadata:
  upstream: inertia-rails-pages
  adapted-for: StarterApp
  version: "4"
---

# hotwire-rails-pages

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Прочитай `app/views/layouts/application.html.erb`, маршруты и `docs/hotwire.md`.
- Тексты UI бери из `config/locales/en.yml` через `t`; даты — через `l`, числительные — через `count`. Правила добавления языков — `docs/architecture.md#языки-интерфейса`.
- Заголовок страницы задавай через content_for :title; семантические heading и основной контент должны сохраняться в Native.
- Ссылки навигации — link_to; мутации — form/button_to. Фильтры и пагинацию храни в query string.
- Для локального обновления используй frame с постоянным id; для нескольких областей — stream templates.
- Повторяемую разметку выделяй в ViewComponent с небольшим явным API.
- Учитывай Turbo cache: подписки/таймеры очищаются в disconnect, временный DOM — до turbo:before-cache.
- Проверяй браузерные Back/Forward, reload с query string, Native back и отсутствие дублированной панели навигации.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-pages.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-pages`.
