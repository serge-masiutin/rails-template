# Права доступа

- HTTP-контроллер вызывает authorize! до чтения защищённых данных или изменения. ApplicationController включает verify_authorized; конкретные правила — наследники ApplicationPolicy.
- Для коллекции применяй authorized_scope и проверку применения scope. Авторизация одной записи не фильтрует остальные строки.
- Домен получает actor или owner явно. UI может скрыть кнопку, но сервер повторно проверяет действие; Native User-Agent не даёт прав.
- В job заново загружай пользователя и запись, проверяй доступ на момент выполнения. Current.user из HTTP туда не переносится.
- Sessions/passwords используют отдельные проверенные пароль/токен-контракты. Панели /ops используют OperationsConfig и Basic, метрики — отдельный Bearer.
- Проверяй гостя, владельца, чужую запись, отзыв сессии и неизвестное правило; default_rule nil сохраняет громкую ошибку неизвестного policy API.

Источники поведения: [app/policies/application_policy.rb](../../../../../app/policies/application_policy.rb), [app/policies/user_policy.rb](../../../../../app/policies/user_policy.rb), [test/controllers/authorization_test.rb](../../../../../test/controllers/authorization_test.rb), [test/policies/user_policy_test.rb](../../../../../test/policies/user_policy_test.rb).
