# Выделить правило доступа

Повторяющуюся проверку владельца замени именованным правилом ApplicationPolicy. Контроллер вызывает authorize! до выдачи данных; UserPolicy#show? — рабочий образец. Сохрани verify_authorized и проверь чужую запись и гостя.

До изменения найди все вызовы. После переноса обнови их атомарно и проверь публичный сценарий. Указанные файлы — действующие примеры; не создавай вымышленные доменные модели ради демонстрации паттерна.

Источники поведения: [app/policies/user_policy.rb](../../../../app/policies/user_policy.rb), [app/controllers/accounts_controller.rb](../../../../app/controllers/accounts_controller.rb), [test/controllers/authorization_test.rb](../../../../test/controllers/authorization_test.rb).
