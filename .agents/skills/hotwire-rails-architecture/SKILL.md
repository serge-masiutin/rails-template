---
name: hotwire-rails-architecture
description: Server-driven Rails architecture for StarterApp web and Hotwire Native Android. Load first for pages, CRUD, forms, navigation, partial updates, or state ownership; routes to the detailed Hotwire skills.
---

# Hotwire Rails Architecture

Server-driven architecture for Rails, Turbo, Stimulus, ViewComponent, and Hotwire Native.
Rails owns routing, data, validation, and access. ERB renders the shared HTML interface;
Stimulus adds local interactions and Android supplies device capabilities.

Use the decision matrix and examples below to choose data ownership, rendering,
navigation, and API boundaries. Read `AGENTS.md` and `docs/architecture.md`.

## The Core Mental Model

The server is the source of truth. A page receives HTML, not a second client-owned copy of
the domain. Turbo navigates and replaces HTML; Stimulus manages temporary browser state.
Do not add a client-side router, a global state store, or a JSON API just to display a page.

Before building a feature, decide:

- **Where does the data come from?** Database and external service results enter through a
  controller/query and are rendered by Rails. Input lives in the form until submitted.
- **Who owns this state?** Shareable/bookmarkable filters belong in the URL; durable state in
  the database; disclosure/open/focus state in the DOM and a small Stimulus controller.
- **Does Android need the same behavior?** Start with working HTML. Add a bridge only for an
  actual device affordance, without changing authentication or validation.
- **Am I duplicating a Rails/Turbo mechanism?** Check the matrix before introducing fetch,
  a cache, a serializer, a job, or another dependency.

## Decision Matrix

| Need | StarterApp solution | Avoid |
| --- | --- | --- |
| Initial page data | Authorized controller query → ERB/ViewComponent | Fetching the same data after rendering an empty shell |
| Shared navigation/auth display | Existing layout/helpers and Action Policy | Sending the whole current user as global JSON |
| Flash messages | Rails notice/alert → `Ui::NoticeComponent` | A second client notification store |
| Submit a form | `form_with` / `button_to`, CSRF, 303/422 | Hand-built fetch submission for ordinary CRUD |
| Page navigation | `link_to`, Turbo Drive, Rails routes | Client-side routing or destructive GET links |
| Replace one region | Turbo Frame with a stable ID | Rebuilding HTML from JSON in Stimulus |
| Update several regions | Turbo Stream response with stable targets | An unrelated request per region |
| Noncritical expensive data | Separate authorized eager/lazy frame request | Holding the first response for unrelated slow queries |
| Long generation/import | Job after commit, persisted state, private updates | Running long work in an HTTP request |
| Pagination | Server query + next link/frame; optional progressive loading | Unbounded collections in HTML/JSON |
| Stable reference data | Ordinary server rendering; measured cache if needed | Assuming a client “once” value remains authorized forever |
| Real-time updates | Existing AnyCable client and private streams | A second Cable client or idle HTTP polling |
| Admin refresh | Invalidation event → authorized HTML/JSON reload | Sensitive payloads broadcast to the browser |
| URL-driven dialog/tab/filter | Validated params → rendered state; GET link/form | State lost on refresh or inaccessible without JavaScript |
| Local ephemeral interaction | Stimulus targets/values/actions | Duplicating persisted records in client state |
| External API/webhook | Explicit boundary with schema/authentication | Mixing webhook protocol into a page controller |

## Rules (by impact)

| # | Impact | Rule | Why |
| --- | --- | --- | --- |
| 1 | CRITICAL | Render server-owned data in Rails | One data lifecycle and one access boundary |
| 2 | CRITICAL | Authenticate and `authorize!` every protected action | Hidden controls and Native User-Agent are not authorization |
| 3 | CRITICAL | Use Rails forms and preserve CSRF | Browser and WebView share the same request contract |
| 4 | HIGH | Use links for reads, forms for mutations | Correct HTTP semantics, keyboard behavior, and Turbo navigation |
| 5 | HIGH | Match frame IDs and stream targets | Turbo must identify the exact region to update |
| 5b | HIGH | Use event-driven refresh with AnyCable | Preserve the project's coalescing, visibility, and reconnect behavior |
| 6 | HIGH | Keep shared state in its owning layer | Layouts render presentation; domain operations receive explicit inputs |
| 7 | HIGH | Use Rails flash for one-time server feedback | Avoid replaying successful notifications from cached snapshots |
| 8 | MEDIUM | Separate noncritical slow work after measuring | A frame adds a request; it does not make an expensive query cheap |
| 9 | MEDIUM | Preserve only the DOM that really owns ongoing state | Permanent elements need stable IDs and must not retain stale private data |
| 10 | MEDIUM | Keep components as renderers | Querying or mutating from a component hides dependencies and causes N+1 |

## Skill Map

Load the skills needed for the concrete workflow; do not load the whole catalog.

| Workflow | Skills |
| --- | --- |
| New HTML page | `hotwire-rails-controllers` + `hotwire-rails-pages` |
| Form and validation | `hotwire-rails-forms` + `hotwire-rails-controllers` |
| Shared UI inputs/dialogs/table | `hotwire-ui-components` + `hotwire-rails-forms` where appropriate |
| Flash feedback | `hotwire-rails-controllers` + `hotwire-ui-components` |
| Lazy or background data | `hotwire-rails-controllers` + `hotwire-rails-pages` |
| URL-driven tabs/dialogs | `hotwire-rails-pages` + `hotwire-ui-components` |
| JSON/Native boundary | `rails-serialization` + `hotwire-contracts` |
| Controller/component/browser tests | `hotwire-rails-testing` |
| Component catalog | `lookbook-hub` → the relevant `lookbook-*` skill |
| Layering and nontrivial operation | `layered-rails` |

## References

Read [architecture-patterns.md](references/architecture-patterns.md) before implementing a
new full-stack feature: each rule has its server, markup, lifecycle, and test implications.
Read [decision-trees.md](references/decision-trees.md) when choosing data loading, state,
navigation, or notification behavior. For a small question covered by the matrix, do not
load the expanded reference just for completeness.

The authoritative project contracts are `docs/hotwire.md`, `docs/native.md`,
`docs/realtime.md`, `docs/observability.md`, and `docs/testing.md`. Versions come from
lockfiles, not these examples. Example `Post`/`Report` classes below describe a feature
being implemented; they are not claims that those models already exist in StarterApp.

## When You DO Need a Separate API

| Signal | Why | Example |
| --- | --- | --- |
| Non-HTML consumer | It needs its own explicit data contract | Webhook, command-line client, integration |
| High-cardinality lookup | A bounded search endpoint can be appropriate | Address/catalog autocomplete with authorization and result limits |
| Binary/streaming output | The response is not a page fragment | CSV/PDF export, file download |
| Existing JS visualization | Its documented schema is the boundary | AgentPrism's cleaned trace JSON |
| Native configuration/bridge | Installed clients need versioned compatibility | `public/configurations/android_v1.json` |

Hotwire Native alone does not require an API: it already consumes Rails HTML, cookies,
CSRF, redirects, and form errors. For a real JSON endpoint, validate at the boundary,
serialize an allowlist, and test absent/malformed fields and access independently.
