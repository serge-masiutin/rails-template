# Rails / Hotwire Configuration

## Initializer and Sources of Truth

Read `Gemfile.lock`, `config/importmap.rb`, `config/application.rb`, the environment files,
`app/views/layouts/application.html.erb`, and `app/configs` before changing configuration.
Typed application settings use Anyway Config and fail fast on invalid required values.
Do not mutate SDK, locale, callback, or controller class configuration during a request.

The installed runtime is Rails/Turbo/Stimulus with Propshaft and importmap. Node builds
Herb tooling and the isolated AgentPrism viewer; it does not replace product HTML with a SPA.

## Version Tracking and Assets

The layout tracks styles/importmap assets, and `ApplicationController` calls
`stale_when_importmap_changes`. Preserve those mechanisms when adding a layout.

```erb
<%= stylesheet_link_tag "application", "tailwind", "data-turbo-track": "reload" %>
<%= render "shared/typography" %>
<%= javascript_importmap_tags %>
```

Read asset names from the actual layout and use the installed asset pipeline.
Rebuild Tailwind after adding utility usage outside an existing `@source` path.

## Flash Keys

StarterApp supports notice/alert through `Ui::NoticeComponent`. A new key is a public UI
contract: add the variant, translations, and tests together. `flash.now` belongs to the
currently rendered response; ordinary flash survives a redirect once.

## History and Cache Control

There are separate cache boundaries:

| Boundary | Mechanism | Verify |
| --- | --- | --- |
| Browser/proxy HTTP cache | Response Cache-Control | Private/admin responses retain no-store where required |
| Turbo snapshot preview | Turbo cache-control meta/helper | Back/forward and preview do not show stale private UI |
| Permanent DOM | Stable ID + `data-turbo-permanent` | Only approved ongoing local state survives navigation |
| Server fragment/query cache | Explicit Rails cache policy | Owner/role/locale/version in the key as needed; invalidation defined |

```erb
<meta name="turbo-cache-control" content="no-cache">
```

Use a per-page head section or existing helper when the feature needs to disable snapshots.
`no-preview` prevents cached previews but has different restoration behavior; choose by
the actual requirement and test. `Turbo.cache.clear()` only clears client snapshots; it
does not revoke a session, clear a server cache, or invalidate a private subscription.

## Error Handling

Normal invalid forms render 422. Bad parameter structures raise 400 through `params.expect`.
Unauthorized actions follow the existing policy handler. Unexpected errors keep their cause
and are reported at the boundary; do not catch everything and return `{}` or blank HTML.

For a frame, provide the matching frame in expected error states. The login page may require
a top-level reload. For invalidation-driven refresh, retain the project's visible failure,
timeout, cancellation, and access-revocation handling. Never label an empty failed fetch as
“no results”.

## Server Rendering and Layouts

Rails already renders HTML on the server. No Node SSR service is needed. Product layouts
must include locale/lang/dir, CSRF/CSP tags, shared Martian Mono typography, Turbo/importmap,
and the appropriate access-aware navigation.

Lookbook uses the `component_preview` layout and development-only mount. A preview supplies
its own explicit component inputs and does not require a signed-in user's private state.
Native WebView consumes the same rendered HTML; Native User-Agent can suppress duplicate
navigation chrome but never changes the access decision.

## Verification

Check initial load, a Turbo visit, a frame request, invalid form rendering, locale
restoration, back navigation, and the relevant Native path. Use `hotwire-rails-testing`;
do not turn a configuration review into an unrelated dependency migration.
