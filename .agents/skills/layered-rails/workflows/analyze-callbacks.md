# Проверка callbacks

1. Найди callbacks, их условия и вызываемые методы; проследи вложенные save/destroy, доставки и HTTP.
2. Определи инвариант записи и атомарный use case. Сохрани необходимую нормализацию; сделай сетевые эффекты явными.
3. Проверь commit, rollback, отказ БД и момент enqueue. Учитывай отдельные primary/queue базы и после-коммитный разрыв.
4. Не меняй callbacks глобально и не отключай Isolator; вынеси только доказанно неподходящую ответственность.

Результат: конкретная цепочка вызовов и проверенный контракт после изменения, без произвольных баллов качества.

Источники поведения: [app/models/user.rb](../../../../app/models/user.rb), [test/integration/password_reset_atomicity_test.rb](../../../../test/integration/password_reset_atomicity_test.rb), [test/lib/transaction_safety_test.rb](../../../../test/lib/transaction_safety_test.rb).
