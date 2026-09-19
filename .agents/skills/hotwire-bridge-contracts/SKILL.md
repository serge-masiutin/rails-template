---
name: hotwire-bridge-contracts
description: "Проектировать и проверять JSON-контракты между Stimulus, Hotwire Native Android."
metadata:
  upstream: inertia-rails-typescript
  adapted-for: StarterApp
  version: "3"
---

# hotwire-bridge-contracts

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Исследуй bridge API именно версий из `docs/native.md` и lock/build files.
- Для компонента опиши name, события, обязательные/опциональные поля, типы, ошибки и допустимые ответы.
- JavaScript BridgeComponent отправляет JSON; Kotlin DTO декодируют тот же контракт.
- Валидируй внешнее сообщение один раз на границе. Неверный payload должен приводить к наблюдаемой ошибке без логирования чувствительных значений.
- Bridge поддерживает отсутствие нативной возможности: обычная HTML-кнопка остаётся рабочей. Это явная progressive enhancement ветка.
- Изменяй JS, Kotlin и fixture payloads атомарно. Старые опубликованные приложения должны понимать серверные изменения.
- Проверь некорректный payload, неизвестное событие, disconnect/reconnect, повторный тап и отсутствие компонента в старом клиенте.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-typescript/SKILL.md`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-typescript`.
