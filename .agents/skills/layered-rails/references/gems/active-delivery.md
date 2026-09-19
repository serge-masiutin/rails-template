# Active Delivery в StarterApp

Источник API: [palkan/active_delivery](https://github.com/palkan/active_delivery),
установленная версия — Gemfile.lock. Abstract Notifier входит в этот gem.

## Действующий контракт

- База — `ApplicationDelivery`. Подключены линии `mailer` и `notifier`.
- События объявляй через `delivers`; `deliver_actions_required = true` запрещает неявные события.
- Текущая реализация:

```ruby
class PasswordsDelivery < ApplicationDelivery
  mailer "PasswordsMailer"
  delivers :reset
end

PasswordsDelivery.reset(user).deliver_later
```

- Имена обработчиков задавай строками, чтобы Rails мог перезагружать классы.
- Для дополнительного канала используй `register_line :push, ActiveDelivery::Lines::Notifier`,
  затем `push "ИмяРеальногоNotifier"` в конкретном delivery.
- Событие и его аргументы должны поддерживаться каждым подключённым обработчиком.
  Не используй `deliver_by`: такого API в установленной версии нет.
- Конкретный notifier наследует `ApplicationNotifier` и задаёт `self.driver` — объект с `call(payload)`.
  Метод события возвращает `notification(body: ..., ...)`. Транспорт выбирается по задаче;
  push/SMS-провайдер в StarterApp ещё не подключён.
- Отправка идёт через `MailDeliveryJob` или `NotifierDeliveryJob`: после commit, с `request_id`.
  Прямую синхронную отправку внутри транзакции не используй.

## Проверка

- Письмо: `assert_enqueued_email_with PasswordsMailer, :reset, args: [user]`.
- Канал: проверь payload, выбор driver, отсутствие отправки при rollback и сохранение `request_id`.
- `AbstractNotifier.delivery_mode = :test` перехватывает вызов до Active Job.
  Для проверки реального enqueue временно используй `:normal` и тестовый driver;
  в teardown восстанови режим. Пример — `test/jobs/notifier_delivery_job_test.rb`.
- Не вводи `:noop` для маскировки отсутствующего транспорта. Сбой отправки должен быть виден в очереди.
