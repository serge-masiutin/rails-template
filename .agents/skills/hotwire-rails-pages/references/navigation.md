# Navigation — Detailed Reference

## Programmatic Navigation and Visit Options

Use a real anchor whenever possible. In a Stimulus action, import `visit` from the pinned
`@hotwired/turbo` package and pass a trusted URL. `action: "advance"` adds history;
`action: "replace"` replaces the current entry.

For frame navigation use anchors/forms with `data-turbo-frame`, or assign a validated
`src` to the actual frame element. `frame.reload()` reloads its configured source;
don't assume it recreates the current page's filtered state if that source is stale.

## Partial Reloads and Search/Filters

Make search a GET form. The URL encodes the query, sort, and relevant filters. A result
frame can update independently while the full route still works when opened directly.
Debounce optional auto-submit, cancel timers on disconnect, and avoid submitting during
IME composition. Ensure only the latest intended query appears; do not mix a second
fetch renderer with Turbo's form response.

When filters change, reset the pagination cursor. Preserve unrelated allowlisted state,
not every arbitrary query key. Decide whether intermediate typing uses replace while
explicit search uses advance. Test direct URL, back/forward, and empty search.

## External URLs

Use a normal external link. For a full browser navigation, disable Turbo where needed;
don't use a SPA-specific `inertia_location`. Rails can redirect to a verified external
destination with `allow_other_host: true`, but only after host/scheme validation at the
boundary. Never use that flag to permit an arbitrary `return_to` parameter.

Native may open an external browser or another destination according to its navigation
delegate/path rules. OAuth/payment redirects need their own established callback/state
and host contracts. Don't invent an embedded login flow from a generic link example.

## History Management

| Interaction | Typical history behavior | Verify |
| --- | --- | --- |
| New document/page | Advance | Back returns to previous page |
| Correcting current URL/filter | Replace when intentionally transient | Back is not polluted by each keystroke |
| Bookmarkable frame/tab | `data-turbo-action="advance"` or replace | Reload serves same selected state |
| Ephemeral disclosure | No URL change | Keyboard state and focus |
| Successful mutation | Server 303 | Refresh does not repeat POST |
| Native sheet | Native path configuration | Close/back resolves the correct stack |

Don't call `history.pushState` and assume Turbo now owns the invented state. A direct
URL must remain renderable. Avoid storing private record payloads in history entries.

## Local Updates Without a Round Trip

Use DOM/Stimulus for transient state such as a selected local disclosure. A Turbo Stream
returned by a server mutation updates persisted state. If JS renders HTML from a string,
that becomes an escaping/security boundary; prefer server-rendered markup or safe DOM
text assignment. Do not recreate arbitrary `replaceProp`/`appendToProp` helpers as a new
global client store.

## Global Events

| Event | Typical use | Lifecycle warning |
| --- | --- | --- |
| `turbo:before-visit` | Intentional unsaved-change guard | Don't block every link globally |
| `turbo:before-cache` | Close temporary dialogs, release snapshot-only state | Preserve intended form restoration |
| `turbo:load` | Navigation completion integration | Stimulus connect is usually enough |
| `turbo:frame-load` | Frame-specific follow-up | Scope to the actual frame |
| `turbo:submit-start/end` | Processing UI | Handle both success and failure |
| `turbo:frame-missing` | Deliberate authentication/full-page boundary | Don't hide arbitrary contract bugs |

Bind with declarative actions or remove listeners on disconnect. Don't register the same
document listener on every Turbo visit. Test a second navigation to reveal leaks.

## Link Prefetching

Turbo Drive can prefetch eligible links on hover; inspect the pinned version before
changing its settings. Prefetch is safe only for idempotent GET endpoints. Disable it
for expensive/side-effectful routes as appropriate, and fix side effects in GET handlers.
Use `data-turbo-prefetch="false"` at the intended scope when necessary.

Snapshot caching, preload/prefetch caches, and Rails/HTTP caches are different.
Don't promise a per-link cache duration without checking
the installed Turbo API. If warm navigation doesn't help measured UX, keep normal links.

## Cache Control and Debugging

- `data-turbo-temporary` removes one-time DOM content before snapshots.
- `<meta name="turbo-cache-control" content="no-cache">` opts a page out of snapshots.
- `no-preview` prevents cached previews while allowing restoration behavior.
- `Turbo.cache.clear()` clears Turbo's snapshot cache, not server/HTTP caches.
- Sensitive operational pages preserve their existing HTTP no-store and client clearing.

Use `turbo_page_requires_reload` for pages that must force a full reload, such as a
deliberate session boundary. Diagnose missing-frame responses first; don't apply full
reload globally to conceal mismatched IDs. During debugging, inspect the actual request
headers, final response status/HTML, target frame, and console before clearing caches.
