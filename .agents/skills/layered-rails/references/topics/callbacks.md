# Callbacks и транзакции

- Callback подходит локальному инварианту записи; внешний HTTP, доставка, публикация и многошаговый use case должны быть явными.
- Сначала построй цепочку save/destroy/callback: условия, порядок эффектов, транзакция и rollback. Не удаляй callback по одному лишь имени.
- Связанные изменения БД объединяй транзакцией. Пример — User#reset_password и Session.revoke_all!: отказ отзыва не оставляет новый пароль со старыми сессиями.
- ApplicationJob, MailDeliveryJob и NotifierDeliveryJob ставятся после commit. Для другого локального callback используй AfterCommitEverywhere.after_commit(without_tx: :raise) внутри явной транзакции.
- Callback после commit не гарантирует доставку после аварии процесса. Надёжное действие выполняй через job; атомарность между primary и queue требует отдельно спроектированного outbox.
- Не меняй глобальные callbacks и не отключай Isolator в запросе или тесте ради обхода проблемы. Проверь успех, rollback и отказ границы.

Источники поведения: [app/models/user.rb](../../../../../app/models/user.rb), [app/models/session.rb](../../../../../app/models/session.rb), [test/lib/transaction_safety_test.rb](../../../../../test/lib/transaction_safety_test.rb), [test/integration/password_reset_atomicity_test.rb](../../../../../test/integration/password_reset_atomicity_test.rb).
