# Архитектура

Основа — [Rails Startup Stack Evil Martians](https://evilmartians.com/rails-startup-stack):
Rails, Turbo, Stimulus, importmap, Tailwind, ViewComponent, Anyway Config и Overmind.
Lookbook показывает компоненты; Minitest и Cuprite проверяют приложение.
Изображения обрабатывает [imgproxy](images.md), оригиналы хранит Active Storage.
Yabeda, JSON-логи и управление задачами описаны в [наблюдаемости](observability.md).

Версии заданы в [.ruby-version](../.ruby-version), [Gemfile.lock](../Gemfile.lock),
[compose.yml](../compose.yml) и [Android build files](../native/android/app/build.gradle.kts).

## Где менять код

| Каталог | Ответственность |
| --- | --- |
| `app/models` | Данные и доменные правила; сложные операции — в пространстве имён модели |
| `app/controllers` | HTTP, проверка параметров, доступ и ответ |
| `app/views`, `app/components` | Общий HTML веба и Android |
| `app/javascript/controllers` | Поведение Stimulus и освобождение ресурсов при отключении |
| `app/configs` | Конфигурация и её проверка через Anyway Config |
| `app/jobs` | Фоновые задачи |
| `app/policies` | Правила доступа Action Policy |
| `app/deliveries`, `app/mailers`, `app/notifiers` | События уведомлений, письма и остальные каналы |
| `native/android` | WebView, мобильная навигация и возможности устройства |

Добавляй отдельный слой, когда у него появляется собственная ответственность.
Очередь и кэш используют Solid Queue и Solid Cache. WebSocket обслуживает
[AnyCable](realtime.md): HTTP RPC в Rails, отдельный Go-сервер и общий клиент веба/Android.

## Языки интерфейса

Сейчас интерфейс и письма доступны только на английском. Документация и комментарии — на русском.
Источник собственных переводов — `config/locales/en.yml`; поддерживаемые языки заданы в
`config/application.rb`. `Localization` принимает `?locale=en`, отклоняет неизвестные значения
с HTTP 400 и применяет `I18n.with_locale` на время запроса. Язык браузера автоматически не выбирается.
Ссылки сохраняют выбранную локаль; ответы задают `Content-Language`, layouts — `lang` и `dir`.

В ERB используй `t`, в Ruby — `I18n.t`, для дат — `l`, для числительных — `count`.
Переводи целое предложение с именованными подстановками. `_html` допускает только доверенную
разметку словаря; пользовательский текст не помечай `html_safe`. Пропущенный перевод вызывает ошибку,
межъязыковой fallback отключён. Active Job сохраняет locale при постановке; письма используют её
при рендере и передают в ссылки. Для будущих рассылок без HTTP язык получателя нужно передавать явно.

Оболочка AgentPrism получает свой небольшой словарь из Rails через экранированный `data-messages`;
JS проверяет его контракт. Встроенные AgentPrism, Mission Control и Lookbook пока английские.
Их перевод — отдельная интеграция при добавлении языка; исходники vendor не редактируем.
Статические страницы ошибок в `public/` и внешний Grafana dashboard также английские.
Они работают вне Rails i18n; для дополнительной локали потребуются отдельные страницы/дашборды.

Чтобы добавить любой новый язык:

1. Добавь полный словарь в `config/locales/<locale>.yml`, включая сообщения Rails,
   названия полей, форматы дат и чисел, plural rules и направление `layout.direction`.
   Выбирай правила языка, а не копируй английские `one`/`other` для всех языков.
2. После проверки включи язык в `available_locales`. Проверь формы, ошибки, письма,
   даты, числа, длинные строки, доступность и отсутствие пропущенных ключей.
3. В Android добавь `res/values-<locale>/strings.xml`, обнови `androidResources.localeFilters`
   и `res/xml/locales_config.xml`. Базовый `values/strings.xml` остаётся английским.
   При выборе языка приложения синхронизируй его с Rails URL; язык ОС сам по себе его не меняет.
4. Для RTL проверь направление, порядок элементов и логические отступы. Проверь покрытие
   символов Martian Mono и согласуй шрифт до публикации языка, если нужных глифов нет.
5. Запусти `test/integration/localization_test.rb`, тесты затронутых экранов, `bin/ci`
   и Android build/lint. Временная французская локаль в тесте проверяет расширяемость;
   в поставляемом приложении она не включена.

Основа: [Rails I18n](https://guides.rubyonrails.org/i18n.html) и
[Android locale resources](https://developer.android.com/guide/topics/resources/multilingual-support).

## Типографика

Все интерфейсы используют [Martian Mono](https://evilmartians.com/products/martian-mono):
веб, Android, AgentPrism, Mission Control и Lookbook. Шрифт хранится в проекте;
CDN и установка в системе не нужны. Поддерживаются русская кириллица, знак рубля и веса 100–800.

Общий веб-слой — `app/assets/stylesheets/typography.css`; новый layout подключает
`shared/typography` после своих стилей. Tailwind `font-sans`, `font-serif` и `font-mono`
обозначают одно семейство. Меняй размер, вес и интервалы; второе семейство не добавляй.
Lookbook рендерит компоненты через `component_preview` с теми же стилями и importmap,
без навигации и зависимости от пользовательской сессии.
Ширина — 100%: у upstream variable-файла исходное значение 112,5%.

Android включает TTF в `res/font`; семейство и тема задают веса, toolbar и Material text appearances.
Общий WebView получает WOFF2 из Rails. Системная клавиатура и интерфейсы ОС используют настройки устройства.

Версия, исходный архив, SHA-256 и лицензия — `vendor/fonts/martian-mono`.
При обновлении сохраняй лицензию и проверяй кириллицу, формы и длинный текст на узком экране.
Локальные layouts Lookbook/Mission Control и `hotwire_error.xml` добавляют шрифтовой слой;
сверяй их с оригиналами при обновлении этих зависимостей.

## Окружения

Development и production имеют отдельные БД primary, queue и cache.
Test использует primary и queue: обычные задания перехватывает тестовый адаптер,
а проверки наблюдаемости работают с настоящей БД Solid Queue. Обычные тесты перехватывают
WebSocket-публикации; `bin/realtime-test` запускает отдельный AnyCable и настоящий браузер.

- Параметры локальной БД: `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD` в [database.yml](../config/database.yml).
  При смене `POSTGRES_PORT` в Compose задай такой же `PGPORT` для Rails.
- Адрес приложения: [config/web.yml](../config/web.yml), локальное переопределение —
  `config/web.local.yml` или `WEB_HOST`, `WEB_PROTOCOL`, `WEB_PORT`.
  Сам `bin/rails` не загружает `.env`; экспортируй переменные перед запуском.
- Production требует параметры БД и SMTP из [инструкции деплоя](deployment.md).
  `SECRET_KEY_BASE_DUMMY` допустим только при сборке ассетов.

## Конкурентное выполнение

Потоки и пулы БД задаёт `ConcurrencyConfig`: значения по умолчанию — в классе,
production-переопределения — в [concurrency.yml](../config/concurrency.yml).
Puma, `bin/jobs`, `queue.yml` и `database.yml` читают этот общий конфиг.
ENV сохраняют штатные имена; локальный YAML — `config/concurrency.local.yml`.

| ENV | Development / test | Production | Назначение |
| --- | --- | --- | --- |
| `RAILS_MAX_THREADS` | 3 | 5 | Потоки одного Puma-процесса; HTTP RPC AnyCable использует тот же пул |
| `JOB_THREADS` | 3 | 3 | Одновременные задания одного worker |
| `JOB_CONCURRENCY` | 1 | 1 | Worker-процессы в fork-режиме |
| `DB_POOL` | 5 | 5 | Максимум соединений с primary/cache на Ruby-процесс и БД |
| `QUEUE_DB_POOL` | 10 | 5 | Максимум соединений с queue на Ruby-процесс |
| `SOLID_QUEUE_SUPERVISOR_MODE` | `async` | `fork` | Размещение worker, dispatcher и scheduler |

Размеры должны быть положительными целыми. `DB_POOL` вмещает максимум потоков Puma/worker.
`QUEUE_DB_POOL` — минимум `max(RAILS_MAX_THREADS, JOB_THREADS + 2)` для fork;
для async заложен запас 7 на служебные потоки общего процесса вместо 2.
При нарушении приложение останавливается до запуска. В async допустим `JOB_CONCURRENCY=1`:
[Solid Queue игнорирует это число в async](https://github.com/rails/solid_queue#fork-vs-async-mode).
Режим меняй через конфиг/ENV, чтобы проверка пулов учитывала его; CLI `--mode` предназначен для разовой диагностики.

Локальный async сохраняется из-за воспроизведённого сбоя pg/libpq после fork на macOS.
По той же причине Rails-тесты на macOS идут в одном процессе, на Linux — в двух;
`PARALLEL_WORKERS` переопределяет число тестовых процессов.

Пул принадлежит процессу, а не всему сервису. При увеличении процессов/контейнеров суммируй
их подключения к каждой БД, включая web, worker, dispatcher, scheduler и консоль;
оставляй резерв под деплой с двумя версиями и обслуживание. Сверяй сумму с PostgreSQL `max_connections`.
Настройки — исходная конфигурация, не результат нагрузочного теста. Перед ростом concurrency
измеряй p95, CPU, память, ожидание БД и возраст очереди. `bin/jobs check` проверяет конфигурацию очереди.
Clustered Puma требует сначала изменить [сбор метрик](observability.md#метрики-и-alerts).

### Правила для кода

- HTTP и jobs исполняет Rails Executor с thread-scoped `Current`. Не храни пользовательские данные
  в переменных класса, singleton-состоянии или скрытой мемоизации Current; добавляй явный `attribute`.
- Задание получает ID пользователя аргументом. `RequestCorrelatedJob` переносит `request_id`,
  изолирует `job_id` в логах и исключает наследование `Current.session`, включая `perform_now` из HTTP.
- При необходимости собственного потока оборачивай прикладной код в `Rails.application.executor.wrap`,
  передавай контекст явно, ограничивай ожидание и получай результат через `Thread#value`.
  Потоки не заменяют долговременную очередь. Не включай fiber scheduler без пересмотра изоляции и библиотек.
- Уникальность защищает индекс БД: валидация Rails не исключает гонку. Изменение общего состояния
  выполняй атомарным SQL или под блокировкой строки; локальный Mutex не защищает другие процессы.
  Для job с ограничением по ресурсу используй `limits_concurrency` Solid Queue и отдельно проектируй идемпотентность.
- Не меняй ENV, callbacks, методы классов и глобальную конфигурацию SDK при обработке запроса/задания.
  `rubocop-thread_safety` проверяет это в `bin/rubocop` и CI; изменение ENV контролируется в `app/` и `lib/`.
  Статический анализ не доказывает отсутствие гонок.
- Isolator обнаруживает сеть внутри транзакций в development/test. Для конкурентных сценариев используй
  отдельные соединения и барьеры с таймаутами, без `sleep`; пример — `test/lib/concurrency_test.rb`.

Rails 8.1 включает YJIT в production и отключает в development/test. ZJIT, M:N и Ractor
не включены дополнительно; их введение требует отдельного сценария, совместимости gems и замеров.
В [релизе Ruby 4.0](https://www.ruby-lang.org/en/news/2025/12/25/ruby-4-0-0-released/)
ZJIT и Ractor ещё отмечены как развивающиеся возможности. Числа ускорения из обзора не являются замерами StarterApp.
Основа правил — [Concurrency Evil Martians](https://evilmartians.com/rails-startup-stack),
[Rails Executor](https://guides.rubyonrails.org/threading_and_code_execution.html)
и [защита от дублей](https://evilmartians.com/chronicles/one-row-many-threads-how-to-avoid-database-duplicates-in-rails-applications).

## Аутентификация

Используется Rails authentication generator: User, Session, подписанная HttpOnly cookie,
CSRF и ограничение частоты входа. Пароль — от 12 символов; верхнюю границу задаёт bcrypt.
Сброс пароля отзывает все сессии. Контроллеры требуют вход по умолчанию.

Action Policy проверяет доступ через `authorize!`; `ApplicationController` обнаруживает
пропущенную проверку. `UserPolicy` разрешает просмотр только своего профиля. Отказ даёт 403,
неизвестное правило — исключение. Вход и восстановление пароля используют собственные проверки
пароля/токена. Админка, Mission Control и AgentPrism требуют сессию и `AdminPolicy#access?`;
Basic `/ops/health` и Bearer `/ops/metrics` остаются отдельными техническими контрактами.
Права `User#admin` выдаются явно; [порядок доступа](observability.md#админка). Native получает те же права, что и веб.

Rails 8.1.3.1 несовместим с JSON 3 при чтении cookies и токенов
([ошибка Rails](https://github.com/rails/rails/issues/58685)). Ограничение `json < 3`
в Gemfile снимай после обновления Rails и проверки сценариев аутентификации.

## Essential gems

Все возможности из списка Evil Martians подключены. Версии — в Gemfile.lock.

| Инструмент | Применение в проекте |
| --- | --- |
| Anyway Config | Проверка web, operations и LLM-конфигурации в `app/configs` |
| Action Policy | Policies и обязательный `authorize!` в прикладных контроллерах |
| Active Delivery | `PasswordsDelivery.reset(user).deliver_later`; новые события объявляются через `delivers` |
| Abstract Notifier | Входит в Active Delivery; `ApplicationNotifier` и очередь `notifiers` |
| ViewComponent | UI-компоненты, Lookbook previews и DOM-тесты |
| N+1 Control | `assert_perform_constant_number_of_queries` в Minitest; проверяет рост SQL на разных объёмах данных |
| Isolator | Ошибка при HTTP, отправке письма или небезопасной постановке задания внутри транзакции в development/test |
| After Commit Everywhere | Явные callbacks после коммита вне модели; проверены вложенные транзакции и rollback |
| Freezolite / Bootsnap | Заморозка строк кода проекта через `Bootsnap.enable_frozen_string_literal(app_only: true)` |
| Active Agent / RubyLLM | ERB-промпты, явные provider/model, генерация через Solid Queue, usage и ошибки без автоматических повторов |
| Herb | HTML/ERB lint, formatter и LSP; команды и конфигурация — [инструменты разработки](development.md) |

[Abstract Notifier объединён с Active Delivery](https://github.com/palkan/abstract_notifier),
поэтому устаревший отдельный gem не установлен.
[Авторы Freezolite рекомендуют Bootsnap](https://github.com/ruby-next/freezolite)
для Ruby 4.0.4+ и Bootsnap 1.24.4+: отдельный hook не нужен.
Заморозка включается в `config/boot.rb`; изменяемую строку создавай через `+"строка"`.
`benchmark` подключён явно для Sniffer: в Ruby 4 он больше не входит в стандартный набор gems.

### Уведомления и транзакции

Вызывай delivery из операции или контроллера. Mailer формирует письмо, notifier — payload канала.
`ApplicationNotifier` ставит `NotifierDeliveryJob` в Solid Queue после коммита и сохраняет `request_id`.
У конкретного notifier задай `self.driver` — объект с методом `call(payload)`;
без транспорта отправка завершается ошибкой. Push/SMS-провайдер пока не подключён.

Jobs и письма уже используют `enqueue_after_transaction_commit = true`.
Для другого действия после транзакции вызывай
`AfterCommitEverywhere.after_commit(without_tx: :raise) { ... }` внутри операции.
Не отключай Isolator для обхода ошибки: вынеси сетевое действие за транзакцию.
Callback не является надёжной очередью: для обязательной доставки используй job;
при требовании атомарности между primary и queue проектируй outbox отдельно.

### LLM

AI-функции используют `ApplicationAgent` и текстовые ERB-промпты; транспорт — RubyLLM.
Генерации выполняются в Solid Queue после commit и сохраняют request/job ID.
Настройки, версии, ограничения и порядок добавления функции — в [Active Agent](agents.md).
