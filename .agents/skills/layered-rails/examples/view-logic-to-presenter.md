# Extract presentation

Use a small presenter for repeated value formatting and ViewComponent for repeated HTML. NoticeComponent validates message/variant and renders escaped text. Preserve Martian Mono, semantics, preview and tests; rendering must not query or authorize.

Find all callers before changing the code. Update them together and test the public journey.
The linked files are actual examples; do not create fictional domain models merely to demonstrate a pattern.

Behavior sources: [app/components/ui/notice_component.rb](../../../../app/components/ui/notice_component.rb), [test/components/previews/ui/notice_component_preview.rb](../../../../test/components/previews/ui/notice_component_preview.rb), [test/components/ui/notice_component_test.rb](../../../../test/components/ui/notice_component_test.rb).
