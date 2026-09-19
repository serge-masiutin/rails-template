# Формы с несколькими записями

- Обычная форма одной модели остаётся Rails form_with + validations. Form object нужен для нескольких записей или самостоятельного контракта ввода.
- Используй ActiveModel для формы: явные атрибуты, errors и публичный save/submit. Не переносишь туда request, cookies или доставку HTTP-ответа.
- params.expect и авторизация остаются на границе контроллера. Доменные инварианты принадлежат моделям.
- Атомарные записи выполняй одной транзакцией, внешние эффекты — после commit через jobs.
- Ошибка рендерит введённые значения и errors с 422, успех перенаправляет с 303; Frame id и Android modal сохраняются.
- Нужны проверки частичной ошибки, rollback, неверного ввода и пользовательского сценария.

Источники поведения: [docs/hotwire.md](../../../../../docs/hotwire.md), [app/views/passwords/edit.html.erb](../../../../../app/views/passwords/edit.html.erb), [test/controllers/passwords_controller_test.rb](../../../../../test/controllers/passwords_controller_test.rb).
