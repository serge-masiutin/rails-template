# Прикладные уведомления

- Вход — конкретная delivery, наследник ApplicationDelivery; она объявляет delivers и выбирает mailer/notifier. Доменная операция вызывает уведомление явно.
- Mailer отвечает за письмо, notifier — за payload своего канала. Abstract Notifier входит в active_delivery; отдельная одноимённая dependency не нужна.
- Для не-email канала укажи driver с call(payload). Отсутствие транспорта должно приводить к ошибке, а не noop. Push/SMS пока не подключены.
- deliver_later проходит через настроенную очередь после commit. Передавай минимальные аргументы; они хранятся в БД Solid Queue, даже если исключены из логов.
- Проверяй enqueue, адресата, контракт payload, rollback, request_id и отказ отправки. Повтор допускается только с явной идемпотентностью.
- Реальная отправка SMTP требует настроенного сервера; тестовый delivery adapter не доказывает доставку в почтовый ящик.

Источники поведения: [app/deliveries/passwords_delivery.rb](../../../../../app/deliveries/passwords_delivery.rb), [app/notifiers/application_notifier.rb](../../../../../app/notifiers/application_notifier.rb), [test/jobs/notifier_delivery_job_test.rb](../../../../../test/jobs/notifier_delivery_job_test.rb), [docs/deployment.md](../../../../../docs/deployment.md).
