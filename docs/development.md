# Инструменты разработки

`mise exec -- bin/setup --skip-server` устанавливает gems, npm-пакеты и pre-commit
Lefthook в этом репозитории. Версии Ruby и Node.js закреплены в `mise.toml`,
Node.js также указан в `package.json` для npm и GitHub Actions.
Node.js нужен Herb и сборке закрытого просмотрщика AgentPrism. Продуктовые экраны используют importmap.
Команды просмотра трасс и сборки — в [agents.md](agents.md#agentprism).

## Редактор

Для VS Code и Cursor список расширений находится в `.vscode/extensions.json`:
Ruby LSP, Herb, Tailwind CSS IntelliSense и EditorConfig. Установи рекомендации workspace
через панель Extensions. Файлы проекта задают настройки; сами расширения автоматически не устанавливаются.

- Ruby LSP использует Ruby из mise, RuboCop из bundle и Rails add-on для моделей, маршрутов и тестов.
  Для Rails add-on нужна доступная development-БД. Ruby форматируется при сохранении.
- Herb проверяет HTML/ERB с учётом Action View. Общие правила редактора и CLI — `.herb.yml`.
  Форматирование и исправления ERB выполняются явно; сохранение файла их не запускает.
- `.editorconfig` задаёт кодировку, переводы строк и отступы.

В другом LSP-редакторе укажи корень workspace и команды:

```sh
mise exec -- bin/ruby-lsp
mise exec -- bin/herb-language-server
```

Обе команды работают по stdio. Ruby LSP использует `Gemfile.lock`, Herb CLI/LSP —
`package-lock.json`. Расширение Herb для VS Code поставляет собственную версию сервера;
перед коммитом результат проверяет закреплённый CLI.

## Проверки и исправления

| Задача | Команда из корня проекта |
| --- | --- |
| Ruby и Ruby-примеры в README/docs | `mise exec -- bin/rubocop` |
| Безопасные исправления Ruby | `mise exec -- bin/rubocop -a путь.rb` |
| HTML/ERB, включая Turbo Streams | `mise exec -- bin/erb-check` |
| Проверка одного шаблона | `mise exec -- bin/erb-check app/views/accounts/show.html.erb` |
| Форматирование шаблона | `mise exec -- bin/erb-format app/views/accounts/show.html.erb` |
| Проверка форматирования без записи | `mise exec -- bin/erb-format --check app/views/accounts/show.html.erb` |
| Полная проверка проекта | `mise exec -- bin/ci` |

Выбор тестов, TestProf, k6 и разбор нестабильных сценариев — в [тестировании](testing.md).

Herb Formatter пока экспериментальный: после применения проверь diff и относящийся к экрану тест.
Форматирование не блокирует CI; ошибки и предупреждения линтера блокируют.
Ruby-блоки в Markdown помечай `ruby`; shell-команды — `sh`. RuboCop проверяет синтаксис
и стиль примеров, но не исполняет их. Архивы, зависимости и skills с учебными антипаттернами
исключены из RuboCop; структуру skills проверяет `bin/skills check`.

RuboCop включает Rails Omakase, `rubocop-thread_safety` и `rubocop-md`.
[RuboCop Gradual](https://github.com/skryukov/rubocop-gradual) нужен при постепенном устранении
накопленных нарушений. Сейчас проверяется весь код без baseline, поэтому Gradual не установлен.

## Git-хук и CI

Перед коммитом Lefthook выбирает проверки по изменённым файлам: RuboCop, Herb, skills
и Native contracts. Линтеры проверяют рабочие файлы целиком, ничего не исправляют
и не добавляют в индекс. Для частично подготовленного коммита учитывай, что проверяется
также содержимое вне staged hunks. БД для этих проверок не нужна.

После изменения `lefthook.yml` выполни `mise exec -- bin/lefthook install`.
Ручной запуск перед коммитом: `mise exec -- bin/lefthook run pre-commit`.
Хук запускает закреплённые инструменты через mise; `mise` должен быть в PATH Git-клиента.
Глобальные Git/SSH и hooks других репозиториев не меняются.

GitHub CI устанавливает npm-зависимости через `npm ci` и повторяет проверки через `bin/ci`,
включая `npm audit`. `.npmrc` запрещает install scripts. Dependabot обновляет Herb одной группой;
при обновлении согласуй версии npm-пакетов, gem `herb` и `.herb.yml`.

Источники: [стек Evil Martians](https://evilmartians.com/rails-startup-stack),
[Ruby LSP](https://shopify.github.io/ruby-lsp/), [Herb](https://herb-tools.dev/configuration),
[Lefthook](https://lefthook.dev/configuration/lefthook/).
