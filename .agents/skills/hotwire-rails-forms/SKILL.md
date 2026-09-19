---
name: hotwire-rails-forms
description: "Создавать формы StarterApp для браузера и Hotwire Native, включая ошибки, загрузки и многосоставные формы."
metadata:
  upstream: inertia-rails-forms
  adapted-for: StarterApp
  version: "5"
---

# hotwire-rails-forms

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Изображения обрабатывает imgproxy через обычный `.variant(...)`; прочитай `docs/images.md`. Не вызывай `.processed`/`preprocessed: true`. При загрузке проверяй пользователя, принадлежность blob, размер и MIME на сервере; signed URL не заменяет авторизацию.

- Используй `form_with`, label, серверные validation errors и обычные submit-кнопки.
- Контракт: GET показывает форму; успешная мутация возвращает 303; неуспешная — HTML формы с 422.
- Frame-форма сохраняет внешний frame id в ответах с ошибками. Переход за пределы frame задавай через `data-turbo-frame="_top"`.
- Stimulus управляет только локальным поведением; сервер повторно валидирует обязательные поля.
- Для нескольких моделей используй form object с явным контрактом и одной транзакцией там, где нужна атомарность.
- Модальные пути меняй в `public/configurations/android_v1.json`, затем запускай `bin/native sync` и `bin/native check` для bundled-копии Android.
- Проверяй disabled submit, повторное отправление, ошибки, клавиатуру, возврат и закрытие modal в вебе и Android.
- Пример: `render :new, status: :unprocessable_entity` при невалидной модели; `redirect_to root_path, status: :see_other` при успехе.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-forms.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-forms`.
