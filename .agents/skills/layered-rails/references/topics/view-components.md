# Компоненты веба и Android

- Выделяй ViewComponent для повторяемого HTML и устойчивых вариантов, а не для каждого div. Класс принимает keyword arguments и проверяет варианты через fetch.
- Данные и разрешённые действия подготовлены снаружи; render не запускает скрытые запросы, изменения БД или сетевые вызовы.
- ERB экранирует пользовательские значения. Формы сохраняют label/type/CSRF, Turbo Frames — id, streams — стабильный target.
- Используй Tailwind tokens и только Martian Mono. Stimulus освобождает listeners/observers в disconnect; Native получает тот же HTML без дублирования платформенной панели.
- Previews живут в test/components/previews. Lookbook использует component_preview с общими стилями, typography и importmap; ему не нужна пользовательская сессия.
- Компонентный Minitest проверяет публичный DOM, Cuprite — интерактивный сценарий и длинный текст на узком экране. Preview не заменяет assertions.

Источники поведения: [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [app/views/layouts/component_preview.html.erb](../../../../../app/views/layouts/component_preview.html.erb), [test/components/ui/notice_component_test.rb](../../../../../test/components/ui/notice_component_test.rb), [test/system/typography_test.rb](../../../../../test/system/typography_test.rb).
