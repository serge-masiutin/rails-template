# Forms in Hotwire Native Android

## Shared HTTP Contract

The WebView submits Rails forms with the same cookies, CSRF, authorization, shape
validation, 303 success redirect, and 422 validation HTML as the browser. User-Agent
can select presentation; it must not weaken access. A bridge is optional enhancement.

## Native Submit Control

If the feature adds a native toolbar button, define its JS/Kotlin message contract in
`hotwire-contracts`. The JS side submits the existing form via `requestSubmit`, preserving
constraints, field names, and submitter intent. Disable/re-enable the native action in
step with form processing and ignore messages from a disconnected screen. Ordinary
HTML controls remain usable without a registered bridge capability.

Do not claim a bridge component already exists: inspect the actual registration lists
and implement/test both sides for a new one. Do not send the complete form or passwords
over the bridge merely to trigger submission.

## Keyboard, Errors, and Navigation

Keep labels visible, choose appropriate input/autocomplete types, and test focus after
422 with the soft keyboard open. A frame update must retain matching IDs. For a form in
a bottom sheet, decide whether successful navigation dismisses the sheet or advances
the underlying screen; use the versioned path rules and existing navigation framework.
Do not simulate the native stack with arbitrary history rewrites in JavaScript.

## Files and Permissions

Use the existing picker contract before adding a native upload pipeline. Test cancelled
selection, device permissions, large files, and resume. Validate files again in Rails.
Release clients use HTTPS; debug cleartext exceptions are not production configuration.

## Verification and Compatibility

Check old clients when changing path rules or messages. Update published configuration
and APK copies together with `bin/native sync`; run `bin/native check`. Run the appropriate
Gradle/browser/request checks from `docs/native.md` and `docs/testing.md`. Report whether
an actual device/emulator was used. Do not equate UA simulation with keyboard, bridge,
picker, back-stack, or lifecycle coverage.
