# ViewComponent: API проекта

- Базовый класс — ApplicationComponent. Компонент и ERB лежат рядом в app/components; preview — в test/components/previews.
- Принимай явные keyword arguments. Для фиксированного варианта используй Hash#fetch; неизвестное значение — ошибка вызывающего кода.
- Render вызывается через render Component.new(...). Не вводи собственный DSL компонентов.
- Повторяемый внешний вид задают tokens Tailwind и общий Martian Mono. Обычная страница, iframe preview и WebView должны получать одинаковый компонент.
- Рабочие тесты используют ViewComponent::TestCase, render_inline и Capybara assertions. Подключение preview layout задаёт config.view_component.previews.default_layout.

Источники поведения: [app/components/application_component.rb](../../../../../app/components/application_component.rb), [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [test/components/ui/notice_component_test.rb](../../../../../test/components/ui/notice_component_test.rb), [config/environments/development.rb](../../../../../config/environments/development.rb).
