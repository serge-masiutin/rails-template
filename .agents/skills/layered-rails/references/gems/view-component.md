# ViewComponent project API

- Inherit ApplicationComponent. Keep the class and ERB together in app/components and previews in test/components/previews.
- Accept explicit keyword arguments. Select fixed variants with Hash#fetch; unknown values are caller errors.
- Render through `render Component.new(...)`; do not create a private component DSL.
- Use shared Tailwind tokens and Martian Mono across ordinary pages, preview iframes and WebView.
- Tests use ViewComponent::TestCase, render_inline and Capybara assertions. Configure the preview layout with config.view_component.previews.default_layout.

Behavior sources: [app/components/application_component.rb](../../../../../app/components/application_component.rb), [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [test/components/ui/notice_component_test.rb](../../../../../test/components/ui/notice_component_test.rb), [config/environments/development.rb](../../../../../config/environments/development.rb).
