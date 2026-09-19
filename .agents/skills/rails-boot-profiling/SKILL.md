---
name: rails-boot-profiling
description: "Измерять и сокращать время загрузки Rails StarterApp по профилю require/initializers."
metadata:
  upstream: rails-boot-profiling
  adapted-for: StarterApp
  version: "3"
---

# rails-boot-profiling

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Сначала воспроизведи медленный boot на зафиксированном Ruby/Gemfile.lock и сохрани baseline.
- Раздели холодный/тёплый bootsnap, development/test/production, процесс web/job.
- Профилируй require и initializers по подходящему инструменту; устанавливай profiler только для конкретного измерения.
- Ищи загрузку development gems в production, IO при boot и повторный парсинг конфигурации.
- Сетевая работа не должна скрываться в initializer или accessor.
- Меняй одну причину, повторяй тот же замер; измерение и команды приложи к результату.
- После оптимизации проверь zeitwerk, assets и тесты. Не жертвуй fail-fast конфигурацией ради скорости.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/rails-boot-profiling/SKILL.md`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/rails-boot-profiling`.
