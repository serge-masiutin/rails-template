# Shared web and Android components

- Extract ViewComponent for repeated HTML and stable variants, not every div. Accept keyword arguments and validate variants with fetch.
- Prepare data and allowed actions outside; rendering must not hide queries, mutations or network calls.
- Preserve ERB escaping, form labels/types/CSRF, frame IDs and stable stream targets.
- Use Tailwind tokens and Martian Mono. Stimulus releases listeners/observers on disconnect; Native receives the same HTML without duplicate platform navigation.
- Previews live in test/components/previews. Lookbook uses component_preview with shared styles, typography and importmap, without a user session.
- Minitest checks public DOM; Cuprite checks interaction and long text on narrow screens. Previews do not replace assertions.

Behavior sources: [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [app/views/layouts/component_preview.html.erb](../../../../../app/views/layouts/component_preview.html.erb), [test/components/ui/notice_component_test.rb](../../../../../test/components/ui/notice_component_test.rb), [test/system/typography_test.rb](../../../../../test/system/typography_test.rb).
