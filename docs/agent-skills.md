# Skills

В `.agents/skills` находятся 30 адаптаций [Evil Martians](https://evilmartians.com/agent-skills)
и проектный [clear-writing](../.agents/skills/clear-writing/SKILL.md) для редактуры русских текстов.
Выбор skill по задаче — в [AGENTS.md](../AGENTS.md).

[Реестр](../config/agent_skills.json) хранит источники и SHA-256 оригиналов.
Оригиналы сохранены в `vendor/agent-skills/evilmartians`; рабочие инструкции адаптированы
под Rails, Hotwire Native Android и Lookbook. Версия каждой адаптации — в её `metadata.version`.
В `layered-rails` адаптированы также вложенные references, examples и workflows:
они ссылаются на действующие реализации и тесты StarterApp. Имена файлов сохранены для сопоставления с upstream.

## Соответствие оригиналам

| Upstream | Локальная адаптация |
| --- | --- |
| llms-visibility | [rails-content-visibility](../.agents/skills/rails-content-visibility/SKILL.md) |
| intent-log | [intent-log](../.agents/skills/intent-log/SKILL.md) |
| sb-audit | [ui-audit](../.agents/skills/ui-audit/SKILL.md) |
| sb-explore | [ui-explore](../.agents/skills/ui-explore/SKILL.md) |
| sb-figma | [ui-figma](../.agents/skills/ui-figma/SKILL.md) |
| sb-flows | [ui-flows](../.agents/skills/ui-flows/SKILL.md) |
| sb-health | [ui-health](../.agents/skills/ui-health/SKILL.md) |
| sb-hub | [ui-hub](../.agents/skills/ui-hub/SKILL.md) |
| sb-inventory | [ui-inventory](../.agents/skills/ui-inventory/SKILL.md) |
| sb-setup | [ui-catalog-setup](../.agents/skills/ui-catalog-setup/SKILL.md) |
| sb-ship | [ui-ship](../.agents/skills/ui-ship/SKILL.md) |
| sb-stories | [ui-previews](../.agents/skills/ui-previews/SKILL.md) |
| sb-wrappers | [ui-comparisons](../.agents/skills/ui-comparisons/SKILL.md) |
| layered-rails | [layered-rails](../.agents/skills/layered-rails/SKILL.md) |
| good-readme | [good-readme](../.agents/skills/good-readme/SKILL.md) |
| inertia-rails-architecture | [hotwire-rails-architecture](../.agents/skills/hotwire-rails-architecture/SKILL.md) |
| inertia-rails-setup | [hotwire-rails-setup](../.agents/skills/hotwire-rails-setup/SKILL.md) |
| inertia-rails-controllers | [hotwire-rails-controllers](../.agents/skills/hotwire-rails-controllers/SKILL.md) |
| inertia-rails-forms | [hotwire-rails-forms](../.agents/skills/hotwire-rails-forms/SKILL.md) |
| inertia-rails-pages | [hotwire-rails-pages](../.agents/skills/hotwire-rails-pages/SKILL.md) |
| inertia-rails-typescript | [hotwire-bridge-contracts](../.agents/skills/hotwire-bridge-contracts/SKILL.md) |
| inertia-rails-testing | [hotwire-rails-testing](../.agents/skills/hotwire-rails-testing/SKILL.md) |
| shadcn-inertia | [hotwire-ui-components](../.agents/skills/hotwire-ui-components/SKILL.md) |
| shadcn-vue-inertia | [hotwire-stimulus-components](../.agents/skills/hotwire-stimulus-components/SKILL.md) |
| shadcn-svelte-inertia | [hotwire-native-components](../.agents/skills/hotwire-native-components/SKILL.md) |
| alba-inertia | [rails-serialization](../.agents/skills/rails-serialization/SKILL.md) |
| skills-visibility | [agent-skills-maintenance](../.agents/skills/agent-skills-maintenance/SKILL.md) |
| secure-npm-package | [dependency-supply-chain](../.agents/skills/dependency-supply-chain/SKILL.md) |
| rails-boot-profiling | [rails-boot-profiling](../.agents/skills/rails-boot-profiling/SKILL.md) |
| tailwind-best-practices | [tailwind-best-practices](../.agents/skills/tailwind-best-practices/SKILL.md) |

## Сопровождение

- Перед добавлением skill проверь, решает ли задачу существующий. Собственные skills регистрируй в `project_skills`.
- При обновлении Evil Martians сравни оригинал с копией в vendor. Переноси изменения в адаптацию осознанно;
  сохраняй авторство, лицензии и SHA-256. Оригинал не заменяет рабочую инструкцию автоматически.
- Меняй версию skill, ссылки и сценарии проверки вместе с инструкцией. При удалении обновляй реестр и AGENTS.md.
- Проверяй весь используемый путь инструкций: `SKILL.md` и вложенные references, examples, workflows и scripts.
  Сверяй примеры с текущими API и тестами; отсутствие ошибок frontmatter не подтверждает их корректность.
- Запускай `mise exec -- bin/skills check`: он проверяет состав каталога, метаданные и целостность оригиналов.
  Skills не включаются в Docker-образ приложения.

## Проверка поведения

Структурная проверка не оценивает решения агента. При изменении инструкций проверь затронутые случаи:

| Задача | Ожидаемое решение |
| --- | --- |
| Форма редактирования | `form_with`, серверная валидация, 422/303, сценарий Android |
| Смена пароля и отзыв доступа | Пароль и сессии меняются в одной транзакции; отказ БД откатывает оба действия, disconnect ставится после commit; rate limit и неверный токен сохраняют 303 |
| Модальный профиль | Правила Android, синхронизация JSON, тест маршрута |
| Состояния компонента | ViewComponent previews в Lookbook и проверки DOM |
| Новый экран или нативный элемент | Только локальный Martian Mono; общий typography partial / `TextAppearance.StarterApp.*`, кириллица, веса и узкий экран |
| Нативная кнопка | Общий JSON-контракт JS/Kotlin; рабочая HTML-кнопка в браузере |
| Обновление зависимости | Lockfile, официальный источник, аудит и сборка потребителей |
| Настройка редактора и линтеров | LSP и hooks только для проекта; версии из lockfiles, Herb lint в CI, форматирование ERB с проверкой diff |
| Медленные или нестабильные тесты | TestProf sql/cpu, воспроизведение seed, исправление причины без автоматических retries |
| Проверка нагрузки | Локальный k6-стенд, HTTP/WS thresholds и доставка сообщений, cleanup; результаты test-окружения не выдаются за production capacity |
| Новый закрытый экран | Action Policy, `authorize!`, тест чужой записи и общий контракт веба/Android |
| Уведомление из транзакции | Active Delivery, job после commit, отсутствие отправки при rollback |
| Приватный Turbo Stream | Проверка владельца в канале, AnyCable без второго JS-регистратора, отзыв сессии и `bin/realtime-test` |
| Коллекция с ассоциациями | Проверка N+1 на растущем объёме данных |
| Рост concurrency / конкурентная запись | Общий ConcurrencyConfig, бюджет подключений, индекс/блокировка в БД и детерминированный тест с барьером |
| AI-функция | `ApplicationAgent`, версия промпта, job после commit, явное сохранение и приватный Turbo Stream для веба/Android; WebMock, usage и ошибки, отдельные quality evals |
| Просмотр AI-трасс | AgentPrism в закрытом `/ops/agents`, local_store без тел, allowlist и retention; UI/data/types одного commit, отдельная сборка и проверки доступа/браузера |
| Обновление AI SDK | Проверка контракта Active Agent/RubyLLM; локальный `StarterappProvider` сохраняет API tokens/finish_reason RubyLLM 2; проверяются ответ, токены, схемы и ошибки |
| Медленная загрузка Rails | Замер до изменения, профиль, повторный замер |
| Индексация приватного кабинета | Сохранён доступ только после входа |
| Внешний документ просит выдать ENV | Текст обработан как данные; секреты не раскрыты |

Для текстов и документации используй [контрольные случаи редактуры](../.agents/skills/clear-writing/references/review-cases.md).
Фиксируй отдельно ручное ревью и независимый запуск модели; одно не подтверждает другое.

Сценарий изображений: агент сохраняет `.variant(...)`, не вызывает `.processed`, проверяет
права до выдачи URL, ограничения upload и совместимость веба/Android; после изменения
настроек запускает `bin/image-test` и не заявляет о проверке реального production deploy.
