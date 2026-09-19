# Новый проект из шаблона

[Создай репозиторий через GitHub Template](https://github.com/serge-masiutin/rails-template/generate), затем клонируй его.
GitHub создаёт отдельную историю; обновления шаблона не применяются к проекту автоматически.

## Имя и Android ID

Из чистого checkout, до `bin/setup` и первого запуска Rails:

```sh
mise exec -- bin/configure --name my_app --android-id com.example.myapp --dry-run
mise exec -- bin/configure --name my_app --android-id com.example.myapp
```

`--name` — snake_case до 36 символов; из `my_app` получаются Ruby namespace `MyApp`,
префикс `myapp` и базы `my_app_development` / `my_app_test` / `my_app_production`.
`--android-id` — собственный application ID, например `com.acme.portal`; Debug добавляет `.debug`.
Отображаемое имя по умолчанию совпадает с Ruby namespace. Тексты интерфейса можно менять после настройки.

Команда меняет исходники, пути Kotlin, имена классов/ресурсов, конфигурацию, метрики,
тесты, документацию и рабочие skills. Оригиналы в vendor, шрифты, лицензии и их SHA-256 сохраняются.
Git remotes, identity, ключи и настройки компьютера команда не меняет.
Параметры записываются в `config/template.json`. Повтор с теми же параметрами ничего не меняет;
переименование уже работающего приложения отклоняется: перенос БД и опубликованного Android ID требует отдельного плана.

Проверь `git diff`, выполни `bin/setup --skip-server`, затем `bin/ci` и сохрани изменения в Git.
GitHub CI настраивает пример, пока шаблон не персонализирован; после настройки проверяет твой проект.

## Локальное окружение и публикация

- В `bin/setup` создаются новые локальные ключи операций, AnyCable и imgproxy. Не копируй их между проектами.
- Для Git настрой имя/email и при необходимости `core.sshCommand` через `git config --local`.
- Домен, SMTP, secrets и registry задаются при [деплое](deployment.md); production-значений в шаблоне нет.
- AI отключён до выбора провайдера, модели и ключа. Продуктовые AI-функции требуют отдельных evals.
- Перед production настрой резервные копии, проверь восстановление, SMTP и канал оповещений.
- Android требует проверки навигации на устройстве и подписи Release своим keystore.

Если запускаешь несколько проектов одновременно, разведи локальные порты и targets Prometheus
по [инструкции наблюдаемости](observability.md). Каждый проект должен использовать собственные БД и тома.
