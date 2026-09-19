---
name: hotwire-rails-setup
description: "Поддерживать и настраивать Rails/Hotwire основу StarterApp, локальный запуск, сборку ассетов и окружения."
metadata:
  upstream: inertia-rails-setup
  adapted-for: StarterApp
  version: "9"
---

# hotwire-rails-setup

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Node.js собирает отдельный React-просмотрщик AgentPrism в `/ops/agents`: `npm run check:agents` и `npm run build:agents`, watcher в Overmind, отдельный Node-stage Docker. Сохраняй общий Hotwire/importmap для веба и Android; инструкции — `docs/agents.md`.

- Изображения: `docs/images.md`; imgproxy запускается через Overmind и Kamal accessory. Сохраняй общий `/images` для веба/Android, read-only storage, подпись, срок URL и ограничения источников; проверяй `bin/image-test`.

- Источники версий: `.ruby-version`, `mise.toml`, `Gemfile.lock`, Dockerfile и native build files.
- Для нового проекта сначала выполни `bin/configure --name my_app --android-id com.example.myapp` в чистом Git checkout; контракт и ограничения — `docs/template.md`. Повторно переименовывать действующее приложение этой командой нельзя.
- Запуск: `mise install`, `mise exec -- bin/setup`, затем `mise exec -- bin/dev`.
- `bin/dev` автоматически запускает Prometheus, Grafana, Loki и Alloy; контейнеры мониторинга живут отдельно от Overmind. Конфиги и остановка — `docs/observability.md`. Не публикуй локальный anonymous Grafana или Loki в production.
- Overmind читает `Procfile.dev` и запускает web, CSS watcher, jobs, AnyCable, imgproxy и AgentPrism watcher; PostgreSQL поднимается через Compose.
- AnyCable использует HTTP RPC и общий секрет Rails/Go. Локальный запуск, закрытые порты и Kamal accessory — `docs/realtime.md`; после изменения транспорта запускай `bin/realtime-test`.
- Используй importmap и vendored JavaScript в `vendor/javascript`; Tailwind собирается Ruby gem. Node.js используется для Herb и отдельной сборки AgentPrism.
- `bin/setup` устанавливает npm-пакеты из lockfile и локальный Lefthook. Настройки LSP/редактора и команды — `docs/development.md`; не меняй глобальные Git/SSH/editor settings.
- `bin/erb-check` запускает Herb lint, `bin/rubocop` проверяет также Ruby-примеры README/docs. ERB форматируй явно через `bin/erb-format` с проверкой diff и тестом экрана; не добавляй автоисправления в hooks.
- Число потоков, процессов, режим supervisor и пулы БД задаёт `ConcurrencyConfig`. Не дублируй их дефолты в Puma, queue.yml, database.yml и Kamal; проверь fail-fast на неверном ENV, `bin/jobs check` и бюджет подключений из `docs/architecture.md`.
- Новую конфигурацию вводи на границе через Anyway Config либо штатный конфиг Rails, с явными обязательными полями.
- После изменений проверь `bin/rails zeitwerk:check`, `bin/rails assets:precompile`, `bin/ci`, затем запуск Overmind.
- Native SDK и Gradle wrapper настраиваются по `docs/native.md`. Новая установка не должна менять глобальный shell profile.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-setup.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-setup`.
