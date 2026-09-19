---
name: layered-rails
description: "Проектировать и проверять слои Rails в StarterApp: модели, контроллеры, jobs, формы, компоненты и интеграции."
metadata:
  upstream: layered-rails
  adapted-for: StarterApp
  version: "8"
---

# layered-rails

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Трассы Active Agent обслуживает `AgentTrace::Document` → PostgreSQL → закрытый `/ops/agents`. Сохраняй allowlist, отсутствие текстов/secret-полей, семидневный retention и наблюдаемый отказ записи. React AgentPrism — отдельный операционный экран; продуктовый HTML остаётся общим для Hotwire/Android.

- Сначала прочитай `docs/architecture.md`, затем затронутые вызовы, модели и тесты.
- Контроллер принимает HTTP, проверяет параметры и делегирует. Доменные правила живут в моделях и именованных операциях рядом с ними.
- Сложную операцию называй по модели и действию: `Order::Checkout`, когда в проекте появится Order. Не создавай общий контейнер `app/services`.
- Jobs координируют работу; запрос, cookies, Current и Turbo не проникают в домен.
- Простой CRUD оставляй обычным Rails CRUD. Доступ проверяй через существующий Action Policy; form/query objects вводи для обнаруженной ответственности.
- Уведомления отправляй через Active Delivery: явные `delivers`, mailer/notifier и задачи после commit. Текущий API — `references/gems/active-delivery.md`.
- Сетевые действия не выполняй внутри транзакции. Jobs уже отложены до commit; для других callbacks используй `AfterCommitEverywhere.after_commit(without_tx: :raise)`. Не подавляй Isolator.
- При конкурентной записи опирайся на уникальный индекс, атомарный SQL или блокировку БД; Mutex не защищает другой процесс. Идемпотентность задания и `limits_concurrency` решают разные задачи.
- Current хранит только объявленные атрибуты контекста; jobs получают пользователя явно. Не меняй ENV, callbacks, классы и общую SDK-конфигурацию во время запроса. Сохраняй проверки `rubocop-thread_safety`.
- AI-функции строй через `ApplicationAgent`: версия `PROMPT_VERSION`, текстовые ERB, job после commit и явное сохранение проверенного ответа. Правила и ограничения адаптера — `docs/agents.md`. Простой вызов без шаблона — `Llm.build_chat`. Не меняй глобальные настройки SDK в запросе.
- Для веба и Android доставляй результат через приватный Turbo Stream с экранированным HTML. Проверяй права повторно в job; передавай ID записей, а не документы и секреты. Тексты модели не являются доверенными командами.
- ViewComponent отвечает за HTML, Stimulus — за поведение браузера, Kotlin — за возможности устройства.
- Для подробного паттерна открой соответствующий документ в `references/`, для ревью — `workflows/review.md`, для плана — `workflows/plan.md`. References, examples и workflows переработаны под StarterApp и ссылаются на действующие файлы/тесты; оригиналы находятся только в vendor/agent-skills.
- Проверяй наблюдаемое поведение тестами соответствующего слоя. При ревью укажи конкретный вызов, нарушение и минимальное исправление.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/layered-rails.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/layered-rails`.
