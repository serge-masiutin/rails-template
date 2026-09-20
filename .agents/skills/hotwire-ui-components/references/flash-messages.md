# Flash Messages and Notifications

## Existing Integration

The application layout renders Rails flash in `#flash` with `data-turbo-temporary` and
`Ui::NoticeComponent`. Its supported variants are `notice` and `alert`; unknown variants
raise through an explicit mapping. The component escapes message text and uses status
versus alert roles. Reuse this contract before adding a notification component.

## Redirects Versus Same-Response Updates

```ruby
redirect_to profile_path, notice: t("profile.saved"), status: :see_other
```

For a same-response stream, set `flash.now` and explicitly render the notice into a
stable target. A frame response needs a place to display its feedback; the outer layout
may not be replaced. Do not set next-request flash for a stream and then replay it on
an unrelated navigation. Follow redirect before asserting its destination notice.

## Repetition, Timing, and Stacking

Two identical successful operations can legitimately produce the same message. Don't
deduplicate by text forever; treat each response as its own event. Prevent replay through
snapshot cleanup. If the design requires a toast queue, define bounded stacking, lifetime,
manual dismissal, hover/focus pause, reduced motion, and error persistence explicitly.
Do not auto-dismiss a critical error before the user can act on it.

## Validation Versus Flash

Field errors belong next to the field and in the form's error summary. A flash notice
describes a completed operation or page-level outcome. Don't replace 422 field errors
with a generic toast, and don't announce the same error through several live regions.
Keep translated full sentences with named substitutions; don't concatenate fragments.

## Safe Data and Native

Render message text escaped. Never pass raw provider errors, trace bodies, secrets, or
HTML from arbitrary content into a toast. A native notification enhancement must not
cause double announcements or remove the web fallback. Authorize the underlying action
independently from its feedback.

## Verification

Check success redirect, stream feedback, invalid form, repeated identical operations,
Back/Forward, keyboard dismissal when present, and access/session loss. Browser tests
are needed for timers/focus/replay behavior; request tests cover message/status/rendering.
