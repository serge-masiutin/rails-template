# Тестирование

Подготовь окружение через `mise exec -- bin/setup --skip-server`; для браузерных тестов нужен Chrome.
PostgreSQL и Docker должны быть запущены. Полная проверка — `mise exec -- bin/ci`.

## Набор проверок

| Слой | Инструмент и команда |
| --- | --- |
| Модели, jobs, политики, HTTP и компоненты | Minitest, `mise exec -- bin/rails test` |
| Веб-интерфейс и Turbo | Capybara/Cuprite, `mise exec -- bin/rails test:system` |
| Реальная доставка AnyCable | Chrome и Go-сервер, `mise exec -- bin/realtime-test` |
| Реальная обработка изображений | imgproxy, `mise exec -- bin/image-test` |
| Короткая нагрузка HTTP/WS | k6, `mise exec -- bin/load-test smoke` |
| Контракты Android | `mise exec -- bin/native check`; сборки — [Android](native.md) |

Minitest запускает тесты в случайном порядке и печатает seed. На Linux обычный набор
использует два процесса, на macOS — один из-за несовместимости fork/Ruby 4/libpq.
Cuprite поднимает ошибки JavaScript; для ожидания DOM используй матчеры Capybara, без `sleep`.
Параметры Cuprite задаются через `driven_by` в `ApplicationSystemTestCase`: Rails перезаписывает
отдельную регистрацию одноимённого драйвера. Запуск Chrome ограничен 30 секундами, команды — 10.
`BrowserDriverTest` проверяет параметры реального браузера после регистрации Rails.
Пулы основной БД и очереди создаются до system fixtures: Isolator отслеживает
открытие и закрытие тестовых транзакций в одном потоке.
Скриншоты падений сохраняются в `tmp/screenshots` и артефакты CI.

Внешний HTTP закрыт WebMock; localhost разрешён для браузера и локальных сервисов.
Мокай сетевую границу и проверяй запрос, ответ, ошибку и число попыток. Пример —
`test/models/llm_test.rb`; запрет незамоканного HTTP проверяет `test/lib/http_isolation_test.rb`.

Active Agent проверяется в `test/agents/application_agent_test.rb`: шаблоны, usage, очередь,
ошибки и приватность логов. Критерии качества AI-функций — в [инструкции по агентам](agents.md).

Для коллекций используй N+1 Control с растущим набором данных. Рабочий пример —
`test/models/queue_snapshot_test.rb`. Установка gem сама по себе не проверяет каждую выборку.
Isolator проверяет побочные эффекты внутри транзакций; не отключай его ради прохождения теста.

## Проверки аутентификации

В test используется MemoryStore: счётчики rate limit действуют, кэш очищается перед каждым тестом.
`PasswordResetAtomicityTest` проверяет отказ БД при отзыве сессий и rollback пароля;
тест создаёт и удаляет собственное ограничение внешнего ключа только в тестовой БД.

## Профилирование

TestProf подключён к Minitest 6. Профили запускаются явно и в одном процессе:

```sh
mise exec -- bin/test-profile sql
mise exec -- bin/test-profile sql test/models/queue_snapshot_test.rb
mise exec -- bin/test-profile cpu
```

`sql` показывает время и число SQL-событий по наборам и отдельным тестам.
`cpu` записывает StackProf dump и JSON в `tmp/test_prof`; файл dump можно прочитать локально:

```sh
mise exec -- bundle exec stackprof tmp/test_prof/stack-prof-report-cpu-raw-total.dump --text --limit 20
```

Сначала измерь проблему, затем меняй setup, fixtures или запросы и повтори тот же профиль.
Проект использует fixtures; FactoryBot и его оптимизации пока не нужны.
В GitHub workflow **Test diagnostics** выбери `sql` или `cpu`; отчёт сохраняется на семь дней.

## Нагрузка HTTP и WebSocket

```sh
mise exec -- bin/load-test smoke
mise exec -- bin/load-test load
```

Команда работает только с локальной `starter_app_test`. Она создаёт временного пользователя,
запускает отдельный Rails/Puma, AnyCable и k6, затем удаляет пользователя, процессы и контейнеры.
Не запускай одновременно с другими тестами: они используют ту же test-БД.
Нужны свободные порты 3200, 8290 и 8291. Rails доступен контейнерам через host gateway;
3200 слушает интерфейсы хоста на время прогона. Development/production-сервер для команды не нужен.

k6 проходит настоящий вход с CSRF и cookie, читает рабочее пространство и профиль,
подписывается на приватный канал и проверяет Turbo Streams от Rails broadcaster.
Origin и авторизация остаются обязательными. Каждое соединение должно получить сообщение;
пустой прогон или только успешный WebSocket handshake не считаются успехом.

| Режим | HTTP VU | WebSocket VU | Длительность нагрузки |
| --- | --- | --- | --- |
| `smoke` | 1 | 2 | 8 секунд |
| `load` | 5 | 20 | 30 секунд |

Подключение и завершение добавляют время к прогону. Сценарий — `test/load/scenario.js`;
версии образов — `compose.yml`. Пороги требуют успешных checks, отсутствия HTTP/WS ошибок
и p95 менее двух секунд для страниц, подписки и доставки. Это исходные проверки стенда,
а не подтверждённые SLO продукта. Test-окружение, один тестовый пользователь и нагрузка
с того же компьютера не позволяют оценивать production capacity.

В `tmp/load-test/<режим>/` сохраняются итог k6, метрики Rails/Yabeda и AnyCable,
а также локальные логи серверов. Новый прогон заменяет отчёты выбранного режима.
CI запускает `smoke` и сохраняет summary/метрики;
**Test diagnostics → load** запускает более длительный сценарий. Артефакты хранятся семь дней.
Для наблюдения за обычным development-окружением используй [Prometheus/Grafana](observability.md).

## Нестабильные тесты

Повтори конкретный тест с seed из падения:

```sh
PARALLEL_WORKERS=1 mise exec -- bin/rails test test/system/authentication_test.rb --seed 12345
```

Проверь общий изменяемый контекст, часы, порядок записей, фоновые операции и ожидание DOM.
Используй time helpers с блоком, fixtures с явными связями, cleanup в ensure/teardown;
конкурентность проверяй барьерами и таймаутами. Не скрывай сбой повторным запуском до успеха
и не добавляй автоматические retries без установленной причины.

Источники: [Testing в стеке Evil Martians](https://evilmartians.com/rails-startup-stack#testing),
[TestProf EventProf](https://test-prof.evilmartians.io/guide/profilers/event_prof),
[AnyCable, k6 и Yabeda](https://evilmartians.com/chronicles/real-time-stress-anycable-k6-websockets-and-yabeda),
[нестабильные тесты](https://evilmartians.com/chronicles/flaky-tests-be-gone-long-lasting-relief-chronic-ci-retry-irritation).

Просмотрщик AgentPrism проверяется в `test/system/agent_prism_test.rb`: дерево вызовов,
атрибуты, RAW, пустое состояние, ошибка загрузки и узкий экран. Backend-тесты проверяют
Basic-доступ, пагинацию, срок хранения и удаление чувствительных полей. Перед отдельным запуском
собери JS/CSS через `npm run build:agents`; `bin/ci` делает это сам.
