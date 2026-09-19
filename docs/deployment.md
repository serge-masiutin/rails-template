# GitHub CI/CD и деплой

## CI

[ci.yml](../.github/workflows/ci.yml) проверяет PR и push в `main`:
Rails с PostgreSQL, браузерную доставку/восстановление AnyCable, k6 smoke для HTTP/WS, преобразование и защиту изображений через imgproxy, production-ассеты,
Docker, правила Prometheus, Android Debug/Lint и Release/R8.
Debug APK сохраняется в артефактах. Release собирается без подписи с `https://build.invalid`
только для проверки. Production secrets в эти jobs не передаются.

В GitHub ruleset потребуй успешные jobs `rails`, `android`, `container`.
Сам workflow защиту ветки не включает. Actions закреплены SHA;
[Dependabot](../.github/dependabot.yml) обновляет Actions, gems, npm, Gradle и Docker.
Node.js используется для Herb и сборки AgentPrism. Docker собирает JS/CSS в отдельном stage;
Node и node_modules не входят в runtime. Типы, SHA-256 upstream и просмотрщик проверяются в CI.
Команды линтеров и локальные hooks — в [инструментах разработки](development.md).
Профили TestProf и более длительный k6-прогон запускаются вручную через **Test diagnostics**;
команды и артефакты — в [тестировании](testing.md).

## Подготовка GitHub

1. Добавь SSH remote `git@github.com:<owner>/<repository>.git` и отправь `main`.
   Задай identity и SSH-ключ через `git config --local`; шаблон не выбирает аккаунт за владельца.
   HTTPS не использует настройки SSH.
2. Создай Environment `production`, разреши ветку `main` и при необходимости назначь reviewers.
3. Заполни variables и secrets ниже. Дай репозиторию Actions access к существующему GHCR package.

### Variables

| Имя | Значение |
| --- | --- |
| `DEPLOY_HOST` | IP или hostname сервера |
| `DEPLOY_USER` | SSH-пользователь с правами Docker |
| `DEPLOY_ARCH` | `amd64` или `arm64` |
| `WEB_HOST` | Домен без протокола и порта |
| `KAMAL_IMAGE` | `owner/starterapp` в нижнем регистре |
| `SMTP_ADDRESS` | Адрес SMTP |
| `MAIL_FROM` | Адрес отправителя |
| `OPERATIONS_GRAFANA_URL`, `OPERATIONS_PROMETHEUS_URL`, `OPERATIONS_LOGS_URL` | Необязательные HTTPS-ссылки в админке; без credentials и токенов |

### Secrets

| Имя | Значение |
| --- | --- |
| `SSH_PRIVATE_KEY` | Отдельный SSH-ключ деплоя |
| `SSH_KNOWN_HOSTS` | Запись ключа сервера, проверенная вне workflow |
| `SECRET_KEY_BASE` | Результат `bin/rails secret` |
| `ANYCABLE_SECRET` | Отдельный результат `bin/rails secret`; общий для Rails и AnyCable, от 64 символов |
| `IMGPROXY_KEY`, `IMGPROXY_SALT` | Два отдельных результата `openssl rand -hex 32`; общие для Rails и imgproxy |
| `DB_PASSWORD` | Постоянный пароль PostgreSQL |
| `SMTP_USERNAME`, `SMTP_PASSWORD` | Доступ к SMTP |
| `OPERATIONS_USERNAME`, `OPERATIONS_PASSWORD` | Технический HTTP Basic для `/ops/health`; пароль от 32 символов |
| `OPERATIONS_METRICS_TOKEN` | Отдельный токен чтения метрик, от 32 символов |

Для GHCR workflow использует `GITHUB_TOKEN` с `packages:write`.
`.kamal/secrets` ссылается на ENV. Вывод `kamal config` может содержать секреты — не публикуй его.

LLM необязателен. Для подключения задай variables `LLM_PROVIDER`, `LLM_MODEL` и secret
`LLM_API_KEY` вместе; при локальном деплое — одноимённые ENV. До подключения оставь все три пустыми.
Это общая конфигурация Active Agent и RubyLLM для web и jobs. Сбор метрик jobs на внутреннем
порту 9394 описан в [наблюдаемости](observability.md).
Настройки и способ вызова — в [архитектуре](architecture.md#llm).

## Развёртывание

[config/deploy.yml](../config/deploy.yml) размещает web, worker, AnyCable, imgproxy и PostgreSQL на одном сервере.
Kamal Proxy завершает TLS и направляет `/cable` в AnyCable, `/images` — в imgproxy, остальные пути — в Rails.
Порты БД, публикаций и метрик AnyCable наружу не публикуются; БД и Active Storage используют постоянные тома.
Web-контейнер выполняет `db:prepare` при запуске.

Перед первым деплоем направь DNS на сервер, открой 80/443 и проверь SSH-доступ.
До приёма пользователей проверь SMTP, настрой резервное копирование БД и файлов и проверь восстановление.
Автоматические резервные копии в проекте пока не настроены.

В workflow **Deploy production** выбери `setup` для первого запуска или `deploy` для обновления.
Деплой начинается после CI и проверок Environment; одновременные запуски выполняются по очереди.

При локальном запуске экспортируй переменные и используй `mise exec -- bin/kamal setup`
или `mise exec -- bin/kamal deploy`. Эти команды на реальном сервере ещё не проверены.
Kamal собирает закоммиченное Git-состояние.
Откат приложения не откатывает миграции — сохраняй совместимость схемы с предыдущей версией.

Обычный `deploy` не обновляет accessories. После смены образа/настроек imgproxy
или его ключей выполни `mise exec -- bin/kamal accessory reboot imgproxy`; при ротации
ключи Rails и сервиса должны совпадать, прежние ссылки станут недействительными.
Том оригиналов подключён к imgproxy только для чтения; backup остаётся общим с Active Storage.

После смены образа или настроек AnyCable
выполни `mise exec -- bin/kamal accessory reboot anycable` из подготовленного окружения.
Это прервёт WebSocket-соединения и очистит историю в памяти. Порядок проверки — в [AnyCable](realtime.md).

Логи, worker health, метрики и подключение сборщика — в [инструкции наблюдаемости](observability.md).

После первого запуска выдайте нужному аккаунту роль администратора по [инструкции](observability.md#админка).
Откройте `/admin`: миграция не выдаёт доступ существующим пользователям автоматически.
