# Логи, метрики и фоновые задачи

Метрики собирает [Yabeda](https://github.com/yabeda-rb/yabeda-rails), рекомендованная
в [Rails Startup Stack Evil Martians](https://evilmartians.com/rails-startup-stack).
Rails Semantic Logger пишет JSON, Mission Control показывает Solid Queue.

## Админка

Открой `/admin` после обычного входа в приложение. Ссылка есть в верхней навигации
и в профиле, в том числе в Android. Обзор показывает доступность БД, heartbeat процессов,
число заданий и возраст очереди. Из общей навигации доступны Mission Control, AgentPrism,
метрики и логи. Снимок обновляется кнопкой «Refresh»; это не проверка SMTP и внешних API.

Обзор сохраняет имена процессов Solid Queue: `Worker`, `Dispatcher`, `Scheduler`.
Состояния заданий соответствуют ключам метрик:

| Название в обзоре | Ключ | Значение |
| --- | --- | --- |
| Ready | `ready` | Ожидает запуска |
| Scheduled | `scheduled` | Запланировано на указанное время |
| Claimed | `claimed` | Назначено Worker для выполнения |
| Blocked | `blocked` | Ожидает освобождения лимита concurrency |
| Failed | `failed` | Завершилось с ошибкой |

Готовое к запуску задание не означает завершённое. Подробнее о фоновых задачах — в Mission Control;
AI traces и spans — в [AgentPrism](agents.md#agentprism).

Права выдаются существующему пользователю через CLI:

```sh
mise exec -- bin/rails admin:grant EMAIL=you@example.com
mise exec -- bin/rails admin:revoke EMAIL=you@example.com
```

Первый аккаунт создаётся по [README](../README.md#первый-аккаунт-и-проверки).
В production выполни ту же задачу через `bin/kamal app exec --reuse`, например:
`bin/kamal app exec --reuse 'bin/rails admin:grant EMAIL=you@example.com'`.
Прямой деплой на реальный сервер этой командой ещё не проверен.

Новые пользователи получают `admin: false`. Самостоятельной выдачи прав в HTTP нет.
`Admin::BaseController` и `AdminPolicy` проверяют роль на каждом запросе, включая
JSON AgentPrism и мутации Mission Control. После отзыва права следующий запрос получает 403.
Гость переходит на форму входа; JSON получает 401. Сброс пароля отзывает сессии.
Страницы закрыты от HTTP/Turbo-кэширования. Отдельная роль не даёт автоматически доступ
к чужим продуктовым данным: их policies остаются самостоятельными.

### Метрики и логи в админке

`/admin/observability` содержит переходы во внешние сервисы и порядок поиска по request/job ID.
Адреса задаются через Anyway Config (`config/operations.local.yml`) или ENV:

| ENV | Назначение |
| --- | --- |
| `OPERATIONS_GRAFANA_URL` | Дашборд Grafana |
| `OPERATIONS_PROMETHEUS_URL` | Интерфейс Prometheus и alerts |
| `OPERATIONS_LOGS_URL` | Интерфейс подключённого хранилища логов |

В production обязательна схема HTTPS. Не помещай credentials и секретные токены в URL.
Ссылки не проксируют сервисы и не передают им сессию или Bearer-токен приложения;
каждый сервис должен иметь собственную защиту. Пустой адрес показывается как «Адрес не настроен».
Наличие ссылки не проверяет доступность сервиса и не подключает сборщик логов.
GitHub Environment variables с этими именами передаются через workflow и Kamal.

## Локальный запуск

`bin/setup` создаёт `config/operations.local.yml` с HTTP Basic для `/ops/health` и отдельным токеном метрик.
Файл исключён из Git и Docker. Для уже установленного проекта выполни `mise exec -- bin/ops setup`.
После изменения credentials перезапусти Rails.

При работающем `mise exec -- bin/dev` запусти:

```sh
mise exec -- bin/ops monitoring
```

Команда поднимает Prometheus и Grafana через профиль Compose `monitoring`.
Обычный `bin/dev` эти контейнеры не запускает.

| Адрес | Назначение и доступ |
| --- | --- |
| `http://localhost:3000/admin` | Обзор и навигация; сессия пользователя с `admin: true` |
| `http://localhost:3000/ops/jobs` | Очереди, ошибки, повтор заданий и процессы; та же сессия администратора |
| `http://localhost:3000/ops/health` | БД и heartbeat воркеров; отдельный HTTP Basic из локального конфига |
| `http://localhost:3000/ops/metrics` | Prometheus-метрики; отдельный Bearer `metrics_token` |
| `http://localhost:3001/d/starterapp` | Дашборд Grafana, локальный режим просмотра |
| `http://localhost:9090` | Запросы PromQL, состояние сбора и alerts |
| `http://localhost:8091/metrics` | Метрики AnyCable; доступ только с локального компьютера |
| `http://localhost:9394/metrics` | Метрики jobs; Bearer `metrics_token`, остальные маршруты закрыты |

Адреса локальных Grafana и Prometheus уже заданы в `config/operations.yml` для development.
Grafana и Prometheus слушают только loopback. Это конфигурация разработки; ссылки на localhost
работают на компьютере с этими контейнерами, а не на отдельном Android-устройстве.
Prometheus собирает данные раз в 15 секунд и хранит до 7 дней, не более 1 ГБ.
Графики скорости требуют нескольких измерений. Остановка: `docker compose --profile monitoring stop prometheus grafana`.

## Найти событие в логах

Приложение и воркеры пишут по одному JSON-событию на строку в `log/development.jsonl` и stdout.
Тесты пишут в `log/test.jsonl`; production — только в stdout контейнера.

```sh
bin/logs
bin/logs --level error
bin/logs --request-id REQUEST_ID
bin/logs --job-id JOB_ID
bin/logs --no-follow --input log/test.jsonl
```

`--level` выбирает точный уровень. По умолчанию команда показывает последние 200 строк
и новые события; `--no-follow` читает весь файл. `--input -` читает JSON из stdin.
Нужен `jq` из Brewfile.

`request_id` приходит в заголовке ответа `X-Request-Id`. В JSON он находится в `named_tags.request_id`.
Событие постановки задачи содержит `payload.job_id`. По нему находятся выполнение и ошибка в другом процессе.
Наши `ApplicationJob` и `MailDeliveryJob` сохраняют исходный `request_id` при сериализации;
внутри выполнения доступны оба идентификатора. У задания планировщика HTTP-контекста может не быть.

HTTP-событие содержит controller/action, статус, длительность, время БД и рендера.
Уровень по умолчанию — `info`; `RAILS_LOG_LEVEL=debug` включает диагностические события.
Локальные JSONL-файлы можно очистить после остановки процессов: `truncate -s 0 log/development.jsonl`.

### Production

При настроенном окружении Kamal:

```sh
mise exec -- bin/kamal web-logs
mise exec -- bin/kamal job-logs
mise exec -- bin/kamal cable-logs
mise exec -- bin/kamal app logs --since 30m --grep REQUEST_ID
```

Docker хранит до пяти файлов по 20 МБ на контейнер приложения.
Это ограничение объёма, а не гарантированный срок хранения.
После удаления контейнера его логи теряются: для длительного хранения нужен внешний сборщик stdout.
Kamal-команды проверены по CLI; подключение к production-серверу ещё не проверено.

## Разобрать сбой очереди

1. Открой `/ops/jobs`: посмотри Failed jobs, Workers, Scheduled и Blocked.
2. Найди `job_id` и связанные логи. Учти исключение, попытки и уже выполненные побочные эффекты.
3. Исправь причину. Повторяй задание только если повтор безопасен; не запускай массовый retry без разбора.
4. Проверь, что failed count уменьшился, а очередь продолжает обрабатываться.

Из терминала: `mise exec -- bin/ops queue`. Команда только читает общую БД очереди.
В development worker и dispatcher запускаются через Overmind; в production — отдельной ролью Kamal `job`.
Число потоков, процессы и пулы БД — в [конфигурации concurrency](architecture.md#конкурентное-выполнение);
`queue.yml` задаёт очереди и интервалы polling.
Периодические задания — в [recurring.yml](../config/recurring.yml); production scheduler очищает завершённые задания раз в час; development/production также удаляют AI traces старше семи дней.
Упавшие задания автоматически не удаляются. Глобальных автоматических retries нет.

`/up` проверяет загрузку Rails и служит healthcheck для Kamal Proxy.
`/ops/health` отдельно проверяет основную БД, доступ к очереди и свежие worker/dispatcher heartbeat;
в production также требует scheduler. При сбое возвращает 503.
Heartbeat обновляется раз в минуту, устаревает через пять минут — это параметры Solid Queue.
Проверка не подтверждает доставку SMTP, доступность всех внешних сервисов или успех каждого задания.

## Метрики и alerts

| Метрика | Смысл |
| --- | --- |
| `starterapp_agent_trace_failures` | Сбои сохранения AI traces; label stage: storage/sdk |
| `imgproxy_requests_total`, `imgproxy_status_codes_total` | Запросы и HTTP-ответы обработки изображений |
| `imgproxy_request_duration_seconds` | Время ответа imgproxy |
| `imgproxy_errors_total`, `imgproxy_workers_utilization` | Ошибки и загрузка обработчиков |
| `rails_requests_total` | HTTP-запросы по controller/action/status/format/method |
| `rails_request_duration_seconds` | Гистограмма времени ответа |
| `rails_db_runtime_seconds`, `rails_view_runtime_seconds` | Время БД и рендера |
| `starterapp_queue_jobs{state=...}` | ready, scheduled, claimed, blocked, failed |
| `starterapp_queue_processes{kind=...}` | Процессы с актуальным heartbeat |
| `starterapp_queue_oldest_ready_age_seconds` | Время ожидания старейшего задания в ready |
| `anycable_go_clients_num` | Активные WebSocket-соединения |
| `anycable_go_publications_total` | Полученные сервером публикации |
| `anycable_go_rpc_error_total` | Ошибки обращений AnyCable к Rails |
| `anycable_go_rpc_pending_num` | RPC-запросы, ожидающие обработки |

HTTP-счётчики относятся к одному процессу Puma и сбрасываются при его перезапуске.
Текущая конфигурация рассчитана на один процесс Puma на контейнер.
Перед включением clustered Puma настрой общий Prometheus store или отдельный exporter;
при нескольких web-контейнерах собирай каждый отдельно.
Очередь читается из общей БД; при сборе с нескольких web-инстансов не суммируй дубли её gauges.
Служебные запросы `/ops/*` и `/up` исключены из HTTP-метрик.

[alerts.yml](../config/observability/alerts.yml) содержит начальные пороги:
недоступность метрик Rails/AnyCable, ошибки RPC, отсутствие worker/dispatcher,
упавшие задания, ожидание очереди и доля HTTP 5xx.
Alerts видны в Prometheus. Отправка уведомлений не настроена — нужны канал и получатель.
Пороги нужно пересматривать по реальной нагрузке; это стартовые настройки, не SLA.

Для production задай secrets из [инструкции деплоя](deployment.md), подключи внешний Prometheus к
`https://<WEB_HOST>/ops/metrics` с Bearer-токеном и перенеси дашборд/правила из `config/observability`.
Сборщик должен иметь только `OPERATIONS_METRICS_TOKEN`, без пароля панели.
Локальный профиль Compose на production не переносится: нужны отдельные хранение, доступ и доставка оповещений.

Метрики AnyCable в production доступны по `http://starterapp-anycable:8091/metrics` только внутри
Docker-сети Kamal. Подключи сборщик к этой сети или используй закрытый туннель; не открывай порт наружу.
Диагностика доставки и особенности логов Go — в [AnyCable](realtime.md).

### Генерации AI

Active Agent пишет `agent.generated`; ищи событие через `bin/logs` по request/job ID.
Метрики `starterapp_agent_generations`, `starterapp_agent_generation_duration_seconds` и
`starterapp_agent_tokens` показывают исходы, длительность и стандартные входные/выходные токены.
Токены кэша и отдельные тарифы провайдера здесь не учитываются; это не расчёт стоимости.
Labels содержат только agent/action/status либо direction; пользовательские ID туда не попадают.
Usage может отсутствовать при ошибке или обрыве — это не означает бесплатный запрос.

`bin/jobs` поднимает сервер метрик на 9394 с той же Bearer-проверкой, что `/ops/metrics`.
В development он слушает loopback, в production — сеть контейнера, без публикации порта на хост.
Prometheus разработки собирает его как `starterapp_jobs`. В production настрой сборщик
на внутренние IP контейнеров роли `job` и порт 9394, с `OPERATIONS_METRICS_TOKEN`;
используй Docker service discovery, чтобы адрес обновлялся после деплоя.
Fork-воркеры делят файловое хранилище счётчиков во временном каталоге supervisor.
После остановки каталог удаляется; новый запуск начинает новые счётчики.
Дашборд суммирует web и jobs. Локальные SDK traces доступны в `/ops/agents`, захват промптов отключён; правила — в [agents.md](agents.md#agentprism).

## Как писать новые события

```ruby
Rails.logger.info(message: "Операция завершена", payload: { event: "operation.completed", job_id: job_id })
Rails.error.report(error, handled: true, source: "starterapp.integration")
```

Используй устойчивое имя события и только необходимые технические поля.
Не записывай request body, cookies, Authorization, аргументы задания, документы и пользовательский текст.
JSON-форматтер убирает параметры, URL, адресатов/тело письма, SQL/binds и известные secret-поля.
Для исключения сохраняются класс и стек с цепочкой причин; произвольный текст ошибки скрыт.
`Rails.error` пишет событие в тот же журнал, без передачи внешнему сервису и без произвольного context.
Форматтер не исправляет небезопасные строки, вручную собранные разработчиком: не интерполируй в message личные данные.

В метки Yabeda не добавляй ID пользователей, запросов, заданий и произвольные URL.
При изменении логирования проверяй отсутствие секретов, связь запрос → задача и сценарий ошибки.
HTTP-запросы Android попадают в те же серверные логи. Нативные crashes/ANR пока доступны через Android Studio/Logcat;
централизованная отправка ошибок клиента не подключена.

imgproxy отдаёт метрики на localhost:8083 в development и `starterapp-imgproxy:8081`
в сети Kamal. Не публикуй этот порт наружу. Панели показывают коды ответов и p95;
alert `StarterAppImagesUnavailable` срабатывает через две минуты без метрик.
Обработка и ограничения логов сервиса — в [изображениях](images.md).
