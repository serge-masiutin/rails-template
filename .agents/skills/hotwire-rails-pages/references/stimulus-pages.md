# Page Composition and Stimulus Lifecycle

## Page Data and Shared State

Render links, titles, flash, and current-user display on the server. Pass interactive
configuration through explicit DOM values. A JSON-consuming visualization uses an
allowlisted schema (`rails-serialization`).

## Titles and Composition

React/Vue Head and Svelte head blocks all solve document metadata. In Rails use
`content_for` and the layout. Render nested UI through ERB partials, component content,
and slots. Pass data and variants explicitly; don't couple a generic visual component
to `params`, Current, or a route-specific query.

## Reactive Local State

Use targets for elements, values for typed configuration, and CSS/classes/attributes for
presentation. Read current input values at the action boundary. For configuration that
can change through DOM updates, use Stimulus value-change callbacks rather than taking
a stale destructured copy once and assuming it stays current.

## Mount, Unmount, and Reconnect

`connect`/`disconnect` are the lifecycle boundary for observers, local requests, timers,
Web Animations, object URLs, and subscriptions. Repeated Turbo visits must not duplicate
them. Use the existing AnyCable/live-update modules for operational refresh; a page
controller should not open its own global socket.

React effect cleanup, Vue watch disposal, and Svelte onDestroy cleanup have the same
purpose here. If an element is permanent, disconnect may not happen on a normal visit;
design its authorization and configuration refresh separately.

## Deferred, Visible, and Infinite Content

Deferred sections and progressive lists use the server, placeholder, error, frame,
and pagination contracts in the main skill. Every separately requested region
authenticates and authorizes again. A
hidden panel can be lazy, but primary document content should not become an empty shell.

## Link Directives and Event Handling

Keep native anchors; attach a narrowly scoped action only for additional behavior.
Avoid `preventDefault` unless the controller actually completes the alternate operation.
Middle click, modifier keys, keyboard activation, and disabled/loading controls remain
part of the navigation contract.

## Regression Cases

Verify direct URL, reload, back/forward, repeated connect, frame replacement, authentication
expiry, missing required DOM configuration, and a late async response after disconnect.
The smallest meaningful test may be a browser scenario covering several of these; don't
write tests that merely assert a framework callback was called.
