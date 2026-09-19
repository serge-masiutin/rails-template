# Объекты авторизации

- Наследуй ApplicationPolicy и задавай именованные предикаты. Неизвестное правило должно поднимать ошибку; не вводи default allow.
- Проверяй нужное действие до данных/мутации через authorize!; для коллекции — authorized_scope и проверка scope.
- Видимость кнопки не заменяет серверное разрешение. Actor передаётся явно, Native User-Agent не влияет на права.
- Нужны Minitest-сценарии владельца, другого пользователя, гостя и неизвестного правила. Для коллекций проверь отсутствие утечек и N+1.

Источники поведения: [app/policies/user_policy.rb](../../../../../app/policies/user_policy.rb), [test/policies/user_policy_test.rb](../../../../../test/policies/user_policy_test.rb), [test/controllers/authorization_test.rb](../../../../../test/controllers/authorization_test.rb).
