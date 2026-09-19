# Rails Template

Основа веб-приложения и Android-клиента на Rails и Hotwire.
Включает вход, админку, фоновые задачи, AnyCable, imgproxy и AI-инструменты.
Локальный запуск — Overmind и Docker; деплой — Kamal; CI — GitHub Actions.

## Создать проект

[Создай репозиторий из шаблона](https://github.com/serge-masiutin/rails-template/generate)
и клонируй его. На macOS установи Homebrew, Docker и Chrome, запусти Docker.
В каталоге нового проекта выполни:

```sh
brew bundle
mise install
mise exec -- bin/configure --name my_app --android-id com.example.myapp
mise exec -- bin/setup --skip-server
mise exec -- bin/dev
```

Замени имя и Android ID на свои. Настройка выполняется до первого запуска.
[Создай аккаунт администратора](docs/template.md#первый-аккаунт).

[Приложение](http://localhost:3000) · [Админка](http://localhost:3000/admin) ·
[Grafana](http://localhost:3001) · [Prometheus](http://localhost:9090)

`bin/dev` также запускает Loki и Alloy для поиска логов в Grafana.
Админка и дашборды обновляются автоматически. Интерфейс — английский, другие языки подключаются через i18n.
Проверка проекта: `mise exec -- bin/ci`. `Ctrl+C` останавливает Overmind;
[контейнеры останавливаются отдельно](docs/observability.md#локальный-запуск).

## Документация

- [Настройка шаблона](docs/template.md) · [Разработка](docs/development.md) · [Тесты](docs/testing.md)
- [Архитектура и i18n](docs/architecture.md) · [Hotwire](docs/hotwire.md) · [Android](docs/native.md)
- [Мониторинг и логи](docs/observability.md) · [Деплой](docs/deployment.md)
- [AnyCable](docs/realtime.md) · [Изображения](docs/images.md) · [Active Agent и AgentPrism](docs/agents.md)
- [Правила агента](AGENTS.md) · [Skills](docs/agent-skills.md)

Основано на [Rails Startup Stack](https://evilmartians.com/rails-startup-stack) и skills Evil Martians.
[MIT](LICENSE) · [Сторонние лицензии](THIRD_PARTY.md).
