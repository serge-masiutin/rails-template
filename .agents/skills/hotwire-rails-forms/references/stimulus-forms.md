# Form State and Component Lifecycle

Use DOM values, Stimulus targets/actions, and Turbo events to manage form interactions.

## Reactive Values and DOM Ownership

Rails renders defaults; an input owns its current value. Read the input when the action
needs it. Use Stimulus values for explicit configuration and small typed state, targets
for required elements, and actions for events. Avoid a copied JS object that can diverge
from the form during browser autofill, restore, or server validation.

Boolean/configuration values encoded in `data-*` are not domain validation. Parse JSON
and validate boundary shape once if a feature needs structured config. Don't use a
framework-shaped global `page.props` object in a Hotwire page.

## Events, Scoped State, and External References

React callbacks, Vue `@submit/@success`, and Svelte event props become declarative
`data-action` handlers scoped to the form. The controller receives the DOM event;
check its documented detail contract. External refs become an HTML `form` attribute
or a required form target plus `requestSubmit`. Keep the triggering submitter so its
name/value reaches Rails. Avoid document-wide selectors when two forms can coexist.

## Processing and Error Presentation

Render validation messages on the server. Processing indicators can react to Turbo
submit events; restore them for 422, forbidden, network error, and cancellation paths.
Do not disable inputs before the browser serializes them; disabled fields are omitted.
If additional buttons are disabled for concurrency, restore their original disabled
state rather than enabling a button that was invalid before submission.

## Connect, Disconnect, and Snapshot Restoration

Stimulus may connect more than once during navigation. Bind listeners once per active
connection and remove them; abort pending local fetches, clear debounce timers, revoke
object URLs, disconnect observers, and release document scroll locks on disconnect.
Use declarative actions where possible because Stimulus manages their listeners.

Close temporary overlays before Turbo caches their DOM. Do not remove persisted input
that the product intends to restore. A controller may reconnect to the same DOM after
cache restoration, so derive initial visual state from that DOM rather than blindly
resetting all controls. Test visit → Back → submit, not only the first full page load.

## Render Blocks and Composition

React children, Vue scoped slots/asChild, and Svelte snippets/child render props become
ViewComponent content/slots and ERB blocks. Pass field name, ID, value, error, disabled,
and described-by explicitly. The visual wrapper must not swallow the real input name,
CSRF token, button type, or accessible label. A custom checkbox still submits the
documented unchecked value; a button inside a form defaults to submit unless specified.

## Shared Scenario Checklist

- Create form: empty defaults, valid save, invalid values remain, translated errors.
- Edit: persisted defaults, explicit cancel, save produces a new dirty-state baseline.
- Delete: correct method, CSRF, cancel sends nothing, forbidden action remains blocked.
- External submit: native constraints and named submitter still work.
- Multiple forms: pending/error state remains local to the submitted form.
- Dynamic input: add/remove/re-add does not duplicate IDs or lose indexed errors.
- Upload: cancellation, object URL cleanup, progress versus final-save distinction.
- Remount/restoration: no duplicate listener/request, no stale success message.

These replace framework syntax differences without introducing three parallel form
implementations. See `hotwire-ui-components` for shared visual input contracts.
