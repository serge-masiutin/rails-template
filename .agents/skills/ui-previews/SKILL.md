---
name: ui-previews
description: "Писать ViewComponent previews StarterApp, документирующие реальные состояния компонента."
metadata:
  upstream: sb-stories
  adapted-for: StarterApp
  version: "3"
---

# ui-previews

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Прочитай API компонента, вызовы, tokens и существующие previews.
- Создай preview-методы для материально различных состояний, без декартова произведения параметров.
- Входы детерминированы: короткий/длинный текст, явные варианты, ошибки, disabled.
- Один preview показывает один понятный сценарий. Повторяющиеся наборы входов можно выделить при явном повторении.
- Preview не заменяет assertions: добавь компонентный тест на публичный контракт.
- Проверь каталог в узком/mobile viewport и клавиатурой; Native navigation проверяется отдельно в приложении.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/sb-stories.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/sb-stories`.
