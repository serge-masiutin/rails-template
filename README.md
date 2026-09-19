# Rails · Hotwire · Android

Шаблон для веб-приложения и Android-клиента с общим Rails-интерфейсом.
Ruby/Rails, PostgreSQL, Turbo/Stimulus, Tailwind и ViewComponent; версии закреплены в lockfiles.

Есть вход и восстановление пароля, фоновые задачи Solid Queue, AnyCable, imgproxy,
логи и метрики Yabeda/Prometheus/Grafana, Active Agent и закрытая панель AgentPrism.
Локальный запуск — Overmind, деплой — Kamal, проверки — GitHub Actions.
Внутри проекта: 30 адаптированных skills Evil Martians и `clear-writing`.

## Создать проект

1. [Создай репозиторий из шаблона](https://github.com/serge-masiutin/rails-hotwire-android-template/generate), выбери имя и видимость.
2. Клонируй созданный репозиторий и перейди в его каталог.
3. Установи Homebrew, Docker и Chrome для браузерных тестов. Запусти Docker, затем выполни:

```sh
brew bundle
mise install
mise exec -- bin/configure --name my_app --android-id com.example.myapp
mise exec -- bin/setup --skip-server
mise exec -- bin/dev
```

Замени `my_app` и Android ID на свои. Команда настройки согласованно меняет Ruby namespace,
имена БД и сервисов, метрики, интерфейс, Kotlin package, тесты и документацию.
Её выполняют один раз, до создания локальных данных. Контракт и `--dry-run` — [настройка шаблона](docs/template.md).

[Приложение](http://localhost:3000) · [Компоненты](http://localhost:3000/lookbook)

Overmind запускает web, Tailwind, jobs, AnyCable, imgproxy и сборку AgentPrism.
`Ctrl+C` останавливает процессы; `docker compose stop` — БД с сохранением данных.
Локальные пароли и ключи создаёт `bin/setup`; они исключены из Git и Docker.

## Первый аккаунт и проверки

Открой `mise exec -- bin/rails console`:

```ruby
require "io/console"
User.create!(email_address: "you@example.com", password: IO.console.getpass("Пароль (от 12 символов): "))
```

Самостоятельной регистрации нет; письма разработки сохраняются в `tmp/mail`.
Полная проверка при запущенной БД: `mise exec -- bin/ci`.
Android Debug использует локальный сервер; для Release нужны HTTPS-адрес и свой keystore.

## Документация

- [Первоначальная настройка](docs/template.md)
- [Редактор, линтеры и Git-хуки](docs/development.md)
- [Тесты, профилирование и нагрузка](docs/testing.md)
- [Архитектура и конфигурация](docs/architecture.md)
- [Формы и навигация Hotwire](docs/hotwire.md)
- [AnyCable](docs/realtime.md) · [Изображения](docs/images.md)
- [Active Agent и AgentPrism](docs/agents.md)
- [Android](docs/native.md)
- [GitHub CI/CD и Kamal](docs/deployment.md)
- [Логи, метрики и задачи](docs/observability.md)
- [Skills](docs/agent-skills.md) · [Правила агента](AGENTS.md)

## Происхождение и лицензия

Основа следует [Rails Startup Stack Evil Martians](https://evilmartians.com/rails-startup-stack)
и использует [их skills](https://evilmartians.com/agent-skills), адаптированные под Hotwire и Android.
Это самостоятельный шаблон, не официальный продукт Evil Martians.
Код шаблона — [MIT](LICENSE); сторонние материалы сохраняют [свои лицензии и авторство](THIRD_PARTY.md).
