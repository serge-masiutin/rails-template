# Граница хранения

- В StarterApp Active Record уже задаёт интерфейс хранения. Не оборачивай find/save в одноимённый repository без дополнительного контракта.
- Для композиции выборки достаточно scope/query object. Отдельный repository нужен, если домен получает собственные объекты из другого хранилища или нескольких источников.
- Зафиксируй вход, тип результата, отсутствие записи, ошибки, транзакцию и владельца данных. Query не выполняет command.
- Проверяй настоящий адаптер хранения на его границе. Подмена всех запросов тестом mocks не подтверждает SQL и целостность данных.

Источники поведения: [docs/architecture.md](../../../../../docs/architecture.md), [app/models/application_record.rb](../../../../../app/models/application_record.rb), [test/integration/password_reset_atomicity_test.rb](../../../../../test/integration/password_reset_atomicity_test.rb).
