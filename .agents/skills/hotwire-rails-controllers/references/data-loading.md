# Data Loading — Detailed Reference

Choose loading boundaries for normal pages, optional and deferred regions, caches,
stream updates, and progressive lists.

## Regular Data

Query what the initial page actually needs. Avoid eager evaluation of unrelated metrics.
Preload associations, bound collections, and use stable sorting with a unique tiebreaker.

```ruby
@posts = authorized_scope(Post.all).includes(:author).order(created_at: :desc, id: :desc)
```

Rendering a focused frame should execute only that region's query. A lambda around a query
is not automatically a deferred endpoint; Rails evaluates it only if your code calls it.

## Optional Regions

Expose an explicit link or frame source when the user requests additional details.
An export uses a dedicated CSV/PDF response, not an optional field in an HTML page envelope.

```erb
<%= link_to t("analytics.details"), analytics_path, data: { turbo_frame: "analytics" } %>
<%= turbo_frame_tag "analytics" %>
```

The endpoint returns `analytics` and rechecks access. Do not mutate state merely because
loading the optional region happens to require a GET.

## Deferred and Grouped Regions

```erb
<%= turbo_frame_tag "analytics", src: analytics_path do %>
  <p role="status"><%= t("analytics.loading") %></p>
<% end %>
```

An eager frame fetches after the initial document appears; `loading: :lazy` waits until it
is visible. Group chart and summary values in one endpoint when they belong to one panel.
Independent panels may have separate endpoints, but avoid a request per tiny field.

Errors, empty data, cancellation, and authorization are visible states. Long work uses a
job with persisted status. A skeleton is not a reason to hide repeated timeouts.

## Reference Data and “Once” Semantics

There is no automatic cross-navigation “once prop” in Turbo. Prefer normal server rendering.
If measurement justifies caching, define the cache owner, key, lifetime, invalidation, and
whether identity/role/locale affect it. Do not store authorization in a permanent element
or assume a value remains valid because the client loaded it earlier.

For immutable public reference data, cache at the server boundary. User-specific settings
must be rechecked after changes. A published Native configuration has an explicit version
and installed-client compatibility rules; it is not an ad hoc browser cache.

## Append, Prepend, Replace, and Nested Updates

Use stable element IDs to match existing records. HTML replacement has no deep object merge.

```erb
<%= turbo_stream.append "posts", partial: "posts/post", locals: { post: @post } %>
<%= turbo_stream.replace "post-count", partial: "posts/count", locals: { count: @count } %>
```

Each rendered post root has `id="<%= dom_id(post) %>"`. For an existing record update,
explicitly replace/update that ID; for removal, remove that ID. Understand duplicate
handling for an append whose child already has the same ID and test the real template.
Do not use record position as identity when filtering or sorting can change it.

For nested data, update the owning component or several named regions. Keep related updates
consistent in one response where possible. A stream target must exist when the message is
applied; test conditional/empty-state markup as well as populated markup.

After-commit delivery prevents clients seeing data that later rolls back. Invalidation
events for admin screens carry no sensitive record payload and trigger a fresh role check.

## Always-Fresh Data

Authentication, authorization, CSRF, and allowed locale remain request boundaries. They are
not cached props copied from a parent response. New forms receive current authenticity
tokens through Rails helpers. Do not let a region's narrow query bypass access enforcement.

## Pagination and Infinite Scroll

Start with a normal next-page link. Check the installed pagination library before copying
its API; StarterApp currently does not have Pagy installed. A bounded relation can implement
a deliberately chosen offset/cursor strategy without inventing a library method.

```erb
<%= turbo_frame_tag "posts" do %>
  <%= render @posts %>
  <% if @next_page %>
    <%= link_to t("pagination.next"), posts_path(page: @next_page, q: @query) %>
  <% end %>
<% end %>
```

Define `@next_page` explicitly as part of the endpoint contract. The optional branch means
“no next page”, not a fallback for a missing required value. Keep filters/sort in the URL.

For append-on-scroll, use a separate stable list target and a replaceable next-page sentinel.
The server returns a bounded chunk and the next cursor; stop when exhausted. Retain a usable
manual “load more” control. An IntersectionObserver may activate that control or load its
frame, but it must avoid concurrent duplicate requests and disconnect when its owner leaves.

Do not assume lazy frames automatically manage pagination history, deduplication, scroll
restoration, or filters. Implement and test the needed behavior explicitly. Upward loading
must preserve the user's reading position; keyboard users need reachable controls and focus.

## Resetting Accumulated Results

When filters/sort/owner change, replace the collection and reset the cursor. Do not append
the first page of a new search to the old search. Cancel an obsolete in-flight request so
a late response cannot repopulate stale data.

A full page visit naturally establishes new HTML. A regional reset needs an explicit
replace of the collection and next-page target. Test a filter change during a pending load.

## Combining Loading Modes

| Combination | Implementation | Failure to prevent |
| --- | --- | --- |
| Deferred + append | Initial frame returns collection/sentinel; later streams append | Missing target when an early event arrives |
| Grouped + refresh | One authorized panel endpoint, one invalidation subscription | Mixing snapshots from different data revisions |
| Optional + append | User opens region, then pages within its own list | Requesting/appending while its target is absent |
| Cached public data + private rows | Separate cache boundaries and access checks | Sharing an owner's content under a public cache key |
| Live updates + user editing | Refresh owned read-only regions, preserve current input | Replacing a form while the user types |

For each combination define IDs, request owner, cancellation, access failure, empty state,
and the check proving the user sees current content. Avoid adding a generic transport
abstraction when one frame and a clear controller action express the contract.
