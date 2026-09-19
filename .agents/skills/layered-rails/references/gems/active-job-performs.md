# Фоновые операции: Active Job и Solid Queue

- В StarterApp явный класс в app/jobs задаёт границу очереди, аргументы и политику ошибок. Даже короткая job полезна, если сохраняет этот контракт.
- Наследуй ApplicationJob; доменную операцию вызывай из perform. Передавай ID, не request, Current.user, документы и секреты.
- Постановка после commit уже включена. Нужны проверки rollback и отказа выполнения, а не автоматическая генерация скрытых jobs из модели.
- retry_on, concurrency limits и таймауты вводи локально по конкретной причине; сначала определи идемпотентность.
- Пример обоснованного retry — DisconnectSessionsJob: ограниченные сетевые ошибки, фиксированное число попыток и идемпотентное отключение.
- Диагностика — /ops/jobs, JSON-логи и метрики WorkerMetrics. Фактические очереди и пулы задают queue.yml и ConcurrencyConfig.

Источники поведения: [app/jobs/application_job.rb](../../../../../app/jobs/application_job.rb), [app/jobs/disconnect_sessions_job.rb](../../../../../app/jobs/disconnect_sessions_job.rb), [docs/observability.md](../../../../../docs/observability.md), [test/models/session_test.rb](../../../../../test/models/session_test.rb).
