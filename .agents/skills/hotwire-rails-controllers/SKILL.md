---
name: hotwire-rails-controllers
description: "Писать HTTP-контроллеры StarterApp с HTML, Turbo Frames/Streams, аутентификацией и Native."
metadata:
  upstream: inertia-rails-controllers
  adapted-for: StarterApp
  version: "4"
---

# hotwire-rails-controllers

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Прочитай `ApplicationController`, concern Authentication и `docs/hotwire.md`.
- Используй `params.expect` для обязательной формы. Неверные параметры дают 400; неверные пользовательские значения — 422 с повторным рендером формы.
- После успешного POST/PATCH/DELETE возвращай redirect со статусом 303. У redirect должен быть известный внутренний адрес.
- Ответ на Turbo Frame содержит frame с тем же id. Turbo Streams используют стабильные dom_id и явные targets.
- Проверяй доступ через Action Policy и `authorize!` до мутации или выдачи данных. `verify_authorized` обязателен по умолчанию; исключение требует отдельного проверенного механизма доступа, как пароль/токен в sessions/passwords. User-Agent Native изменяет представление, а не права.
- Для коллекции применяй `authorized_scope` и `verify_authorized_scoped`; одно только `authorize!` не фильтрует строки. Нужны тесты чужих записей.
- Прикладное уведомление вызывай через delivery; не рассыпай прямые вызовы mailer по контроллерам.
- Для Native сохраняй cookie/CSRF-механизм Rails; не вводи токены в URL.
- Тесты покрывают гостя, вошедшего пользователя, malformed input и успешный/неуспешный ответ; существующие статусы меняй осознанно.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-controllers.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-controllers`.
