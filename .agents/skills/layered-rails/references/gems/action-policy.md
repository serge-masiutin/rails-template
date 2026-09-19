# Action Policy в StarterApp

Источник API: [palkan/action_policy](https://github.com/palkan/action_policy),
версия — Gemfile.lock. Начни с `ApplicationController`, `ApplicationPolicy` и `UserPolicy`.

## Контракт

- Контекст policy — `user`, из контроллера передаётся `Current.user`.
- До чтения приватных данных или мутации вызови `authorize! record, to: :имя_правила?`.
  Для стандартного action правило выводится из его имени.
- `ApplicationController.verify_authorized` обнаруживает пропущенный вызов.
- Policy наследует `ApplicationPolicy`. Неизвестное правило вызывает исключение;
  объявляй разрешения явно и не добавляй общий admin/fallback без доменной необходимости.
- Отказ `ActionPolicy::Unauthorized` даёт 403. Пропущенная проверка — ошибка реализации;
  её нельзя превращать в обычный отказ или скрывать через rescue.
- Список фильтруй через `authorized_scope` и соответствующий `relation_scope` в policy;
  добавь `verify_authorized_scoped` для action списка. Один `authorize!` строки не фильтрует.
- Исключение из проверки допустимо для отдельного механизма доступа:
  пароль/подписанный токен в sessions/passwords, Basic Auth в `/ops/health` и Bearer в `/ops/metrics`. Панели требуют `AdminPolicy#access?`.
  Новый публичный action требует явного решения и теста.
- Native User-Agent не является авторизацией. Cookies, CSRF и policies общие для веба и Android.

## Проверка

Minitest: `test/policies/user_policy_test.rb`, `test/controllers/authorization_test.rb`,
`test/integration/navigation_test.rb`. Проверь владельца, чужую запись, гостя,
неизвестное правило и пропущенный `authorize!`; для списка — исключение чужих строк.
