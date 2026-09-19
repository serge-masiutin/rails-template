---
name: hotwire-stimulus-components
description: "Создавать интерактивные компоненты StarterApp на Stimulus с корректным Turbo lifecycle."
metadata:
  upstream: shadcn-vue-inertia
  adapted-for: StarterApp
  version: "3"
---

# hotwire-stimulus-components

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Используй controllers в `app/javascript/controllers`, targets/actions/values и data-атрибуты ERB.
- Контроллер отвечает за одну локальную UI-задачу. Доменные вычисления и права остаются на сервере.
- Используй event.currentTarget и явные target/value контракты. Не считывай состояние из произвольных глобальных переменных.
- Подписки, observers и таймеры освобождай в disconnect. Повторный connect не создаёт дублированные обработчики.
- Обновляй aria-expanded/hidden и фокус вместе с визуальным состоянием.
- Проверяй взаимодействие через Cuprite после обычной загрузки и после Turbo-перехода назад/вперёд.
- Нативную возможность устройства выноси в BridgeComponent и согласуй с Kotlin.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/shadcn-vue-inertia.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/shadcn-vue-inertia`.
