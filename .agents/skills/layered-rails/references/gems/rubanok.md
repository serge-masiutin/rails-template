# Фильтры и параметры Rails

- На HTTP-границе разбери параметры через params.expect и явные преобразования. Сортировка выбирается из фиксированной карты, никогда не вставляется в SQL напрямую.
- Применяй фильтры к уже разрешённому пользователю scope. Параметры фильтра остаются в query string для Turbo navigation, reload и Android.
- Один простой фильтр оставляй рядом с запросом. Повторяемую композицию вынеси в query/filter object с явными аргументами; не вводи DSL ради одного экрана.
- Отклоняй некорректную дату, неизвестную сортировку, отрицательный размер и повреждённый cursor; не превращай их в бесшумные дефолты.
- Проверяй два соседних значения cursor, крайний размер страницы, чужие записи и число SQL-запросов.

Источники поведения: [app/controllers/operations/agents_controller.rb](../../../../../app/controllers/operations/agents_controller.rb), [test/controllers/operations/agents_controller_test.rb](../../../../../test/controllers/operations/agents_controller_test.rb).
