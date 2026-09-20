# Hotwire Native Navigation

## One HTML Interface

Web and Android share routes, cookies, CSRF, forms, authorization, and HTML. Native
presentation chooses chrome and destination type through existing Hotwire Native
configuration. Keep normal browser navigation usable before adding device affordances.

## Path Rules and Destinations

Read `public/configurations/android_v1.json`, its APK copies, and the real Kotlin
destination registrations. Match specific paths before broader patterns according to
the installed framework's matching rules. Decide default screen versus bottom sheet,
refresh behavior, and back-stack transitions with actual feature URLs.

Update versioned published configuration and bundled copies together with `bin/native
sync`; run `bin/native check`. Preserve installed clients. An incompatible rule/message
change needs a new contract version while old clients retain their compatible endpoint.

## Chrome, Titles, and Back

Avoid duplicate web/native headers. Keep the page title accurate for native chrome and
browser tabs. Test links from inside a frame, direct deep links, sheet close, successful
form redirects, authentication expiry, logout, and Android Back. A JS `history.back()`
is not a universal substitute for a native navigator action.

## External Destinations and Bridge

Use the established external-browser/delegate behavior for non-app hosts. Release uses
HTTPS. A bridge is appropriate for device capabilities or native controls, not a parallel
JSON data API. Define required messages and response semantics in both JS/Kotlin and
retain a functioning HTML alternative when a capability is absent by contract.

## What Counts as Verification

Request tests can validate UA-dependent markup and route/config contracts. Browser tests
can validate Turbo history and frame behavior. Only device/emulator exercise verifies
native back stack, sheets, keyboard, bridge lifecycle, and external app handoff. Report
these separately; inspect `docs/native.md` for available build/test commands.
