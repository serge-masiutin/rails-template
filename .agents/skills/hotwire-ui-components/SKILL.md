---
name: hotwire-ui-components
description: "Создавать переиспользуемые UI-компоненты StarterApp с ViewComponent и Tailwind."
metadata:
  upstream: shadcn-inertia
  adapted-for: StarterApp
  version: "4"
---

# hotwire-ui-components

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Используй только локальный Martian Mono через общий шрифтовой слой; меняй размер, вес и интервалы, а не семейство. Проверь компонент и preview с кириллицей, длинным текстом и на узком экране.
- Найди существующий компонент и токены в `app/assets/tailwind/application.css`.
- Компонент размещается в `app/components`, preview — в `test/components/previews`, тест — в `test/components`.
- Используй keyword arguments и фиксированную карту вариантов; неизвестный variant отклоняй через fetch.
- Сохраняй полные Tailwind class literals, чтобы компилятор находил их. Не собирай `bg-#{color}`.
- Вывод экранируется Rails. HTML-безопасность пользовательских строк не отключается.
- Кнопка имеет корректный type, поле label, dialog управление фокусом. Компонент работает с touch и клавиатурой.
- Проверь preview, семантический DOM и пользовательский сценарий с Turbo.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/shadcn-inertia.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/shadcn-inertia`.
