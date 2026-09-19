# Фильтры коллекций

- Внешний ввод разбирается один раз; объект фильтра получает проверенные значения и уже авторизованный scope.
- Пустой опциональный фильтр и невалидный фильтр — разные случаи. Для malformed input возвращай ошибку, а не весь dataset.
- Сортировка использует allowlist; значения SQL передаются параметрами. Размер страницы ограничен, порядок детерминирован.
- Возвращай relation, если следующий слой ещё добавляет условия; не делай преждевременный to_a.
- Проверяй комбинации фильтров, cursor, граничный размер и недоступные записи.

Источники поведения: [app/controllers/operations/agents_controller.rb](../../../../../app/controllers/operations/agents_controller.rb), [test/controllers/operations/agents_controller_test.rb](../../../../../test/controllers/operations/agents_controller_test.rb).
