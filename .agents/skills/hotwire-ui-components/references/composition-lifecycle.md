# Component Composition and Lifecycle

## Default Versus Controlled Values

The rendered default and current input value are distinct. Use
Rails to render initial/invalid values; read current DOM values when submitting. Do not
overwrite a focused input with a stale server or controller value after every update.
Reset deliberately to either markup defaults or newly persisted server values.

## Slots and Event Forwarding

Composition must preserve exactly one semantic control: an anchor for navigation, a button for an action, a labelled input for
data. Use ERB blocks and ViewComponent slots. Never nest a button inside another button
or a form inside a form. Forward required attributes explicitly, including names, IDs,
disabled, aria attributes, and Stimulus actions.

## Refs and External Controls

Use an HTML form association or required Stimulus target for an external control.
Programmatic submission uses `requestSubmit` so constraints and Turbo events
still apply. A native toolbar action should target the same form, not implement a second
request. Check lifetime: a reference from a disconnected dialog/page is no longer valid.

## Reactive Access and Local State

Don't copy shared page data into a stale local object. Stimulus value-change callbacks
handle changing configuration; required targets expose contract violations. Transient
open/search/focus state remains local. URL-backed tabs/filters come from the URL and
server validation. Durable settings are saved on the server, not hidden in a component.

## Processing and Error Slots

Use Turbo submit events for processing state and server-rendered errors for validation. A visual component must preserve a real
submit button and the complete error association. On 422 keep the dialog open and entered
values intact; on success use the chosen 303/stream path. Never assume every completed
request was successful.

## Cleanup and Reconnect

Use explicit disconnect and before-cache handling.
Remove global listeners, clear timers, abort local requests, disconnect observers, revoke
object URLs, close temporary overlays, and release scroll locks. Permanent DOM has a
different lifetime and needs an explicit reauthorization/reset contract.

## Dark Mode and Head Variants

Define initial preference, system changes, saved override, persistence, and cleanup.
Implement themes with CSS tokens and existing page initialization when requested.
Use the Rails layout for page titles and head content.
