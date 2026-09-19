# Presenting values

- Presenters handle repeated value formatting; repeated HTML belongs in ViewComponent/ERB.
- Pass prepared values/records. Reading a formatted field must not issue HTTP, mutate state or lazily fetch associations.
- Make locale, timezone and units explicit; do not replace unknown enums with empty strings.
- Keep text escaped. Shared Martian Mono owns the font family, not a presenter.
- Test actual values, boundaries and consumer semantic DOM rather than whole-page snapshots.

Behavior sources: [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [test/components/ui/notice_component_test.rb](../../../../../test/components/ui/notice_component_test.rb), [docs/hotwire.md](../../../../../docs/hotwire.md).
