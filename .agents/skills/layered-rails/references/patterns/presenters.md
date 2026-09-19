# Представление значений

- Presenter нужен повторяемому форматированию значений. Повторяемая HTML-структура принадлежит ViewComponent и ERB.
- Передавай готовые записи/значения. Чтение форматированного поля не должно отправлять HTTP, менять состояние или скрыто загружать ассоциации.
- Локаль, часовой пояс и единицы должны быть известны; неизвестный enum не маскируется пустой строкой.
- Текст остаётся экранированным. Семейство шрифта не выбирается presenter: действует общий Martian Mono.
- Проверь реальные значения, границы и семантический DOM потребителя без snapshot всего HTML.

Источники поведения: [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [test/components/ui/notice_component_test.rb](../../../../../test/components/ui/notice_component_test.rb), [docs/hotwire.md](../../../../../docs/hotwire.md).
