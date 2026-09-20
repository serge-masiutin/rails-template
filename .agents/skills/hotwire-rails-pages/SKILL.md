---
name: hotwire-rails-pages
description: Rails pages, layouts, Turbo navigation, frames, deferred sections, progressive pagination, URL-driven state, and Stimulus lifecycle for StarterApp web and Hotwire Native.
---

# Hotwire Rails Pages

Build server-rendered pages with ERB/ViewComponent, Rails layouts, and Turbo. Establish
data ownership, choose the layout, make navigation and URL state explicit, then add
deferred sections and progressive loading where needed.

## Page Structure

Load authorized data in the controller, set the page title, render reusable components,
and use semantic links/forms. Example `Post` names describe a feature to implement.

```erb
<% content_for :title, t("posts.index.title") %>
<main>
  <h1><%= t("posts.index.title") %></h1>
  <%= form_with url: posts_path, method: :get do |form| %>
    <%= form.label :q, t("posts.search") %>
    <%= form.search_field :q, value: params[:q] %>
    <%= form.submit t("posts.filter") %>
  <% end %>
  <%= turbo_frame_tag "posts" do %>
    <div id="post-list">
      <%= render @posts %>
    </div>
  <% end %>
</main>
```

The controller validates filters and scopes results before rendering. Expose only values
the template uses; don't serialize a page-sized JSON blob merely to hydrate Stimulus.
All first-party text uses English Rails translations. Keep Martian Mono and shared
typography in every layout, including previews and operational pages.

## Persistent Layouts

The application layout provides shared chrome. Turbo replaces page bodies while managing
history and snapshots; it does not keep a React/Vue/Svelte component tree mounted.
Use `data-turbo-permanent` only for a concrete continuing DOM resource with the same
unique ID on both pages. It is not a general solution for a sidebar or form.

Read [layouts.md](references/layouts.md) for single/default/conditional/nested layouts,
shared data, scroll regions, and the distinction between layout reuse and DOM persistence.

## Navigation

Use `link_to` for reads and `button_to`/`form_with` for mutations. Routes come from Rails.
Prefer links even when a click could call `Turbo.visit`; users retain open-in-new-tab,
copy-link, keyboard, and accessibility behavior.

```erb
<%= link_to t("posts.show"), post_path(post) %>
<%= link_to t("posts.edit"), edit_post_path(post), data: { turbo_frame: "post-editor" } %>
<%= link_to t("navigation.all_posts"), posts_path, data: { turbo_frame: "_top" } %>
```

When an interaction truly needs programmatic navigation:

```javascript
import { visit } from "@hotwired/turbo"

visit(url, { action: "advance" })
```

The URL must come from an explicit trusted route/configuration contract. Don't promote
arbitrary user input into a redirect. Read [navigation.md](references/navigation.md)
for history, frames, external URLs, events, prefetch, and cache control.

## URL-Driven State: Dialogs, Tabs, Filters

Use the URL when state must survive reload, be shareable, or participate in Back/Forward.
Validate allowed tabs/sort keys on the server; render the selected state from the result.
GET forms encode filters. Preserve unrelated allowed query parameters and reset a cursor
when its filter/sort changes. A hidden tab is not authorization for its endpoint.

For a dialog with a URL, direct navigation must render a usable full-page form; navigation
from its trigger can request the matching frame/dialog. Closing restores the intended
return route, not an arbitrary unvalidated URL. Decide push versus replace deliberately.
For transient help/popovers, local DOM state is usually enough.

## Deferred Sections

An eager `src` frame makes a separate authorized request after its parent loads. This
is the counterpart to noncritical deferred props; the initial page should not perform
the expensive query too.

```erb
<%= turbo_frame_tag "analytics", src: analytics_path do %>
  <p role="status"><%= t("analytics.loading") %></p>
<% end %>
```

```erb
<%= turbo_frame_tag "analytics" do %>
  <%= render "analytics/summary", summary: @summary %>
<% end %>
```

Do not repeat `src` on the destination response and accidentally start another load.
Keep placeholder dimensions sensible; loading, empty, failed, and unauthorized are
different states. Several independent sections can use separate frames; measure request
count before splitting every small query into its own request.

For long generation, persist status and run a job after commit. Deliver a private event
through existing AnyCable, then render/reload authorized HTML. A frame is not a job queue.

## Load When Visible

Add `loading: :lazy` to a `src` frame for below-the-fold content. The response still needs
its matching frame ID and access check. Lazy loading can make search/find/navigation
content unavailable before visibility; keep primary page content eager.

If the product needs custom thresholds or repeated observation, use a small observer
with disconnect cleanup and an explicit loading/error guard. Do not load the same
page repeatedly because a sentinel remains in view after failure.

## Infinite Scroll

Start with an ordinary next-page link and bounded server query. Choose a stable sort
with a unique tiebreaker. Reset cursor/list when filters change; encode cursor state in
the URL if history needs it. StarterApp does not currently install Pagy: use existing
pagination or add a justified dependency only as part of the requested feature.

For progressive loading, a next-page frame can return streams that append rows and
replace the next-page sentinel. The response must match its selected frame/stream
transport. Keep stable row IDs, remove duplicate rows on reconnect/retry, prevent
overlapping page loads, and preserve an accessible manual-load control and end state.

Test empty first/last pages, changing sort mid-load, back navigation, removed records,
failure/retry, and foreign cursors. Very long lists may need measured windowing; don't
add virtualization preemptively or break browser Find and accessible list semantics.

## Refresh and Optimistic UI

Reload one authorized frame when its data changes, or return a stream from the mutation
that changes several targets. For operational pages, follow `docs/observability.md`:
event-driven invalidation, coalescing, visibility pause, input/selection preservation,
failure indication, and clearing on role loss. Reuse existing live-update modules.

Client-side prop helpers do not have a direct Hotwire equivalent. A local UI toggle
can update the DOM; persisted state changes need the server. If an optimistic feature
is justified, specify rollback, duplicate commands, access loss, and reconciliation.
Do not hide a failed save by leaving optimistic HTML on screen.

## Head, Titles, Flash, and Shared Data

Use Rails `content_for :title` and the layout's head. Shared navigation/auth state comes
from existing helpers/current context and Action Policy. Flash already renders through
`Ui::NoticeComponent`; avoid a second client toast store. Use `data-turbo-temporary` for
one-time feedback so a cached visit doesn't replay it.

Preserve CSRF/CSP tags, importmap loading, tracked assets, and the private stream
subscription. The app imports `@hotwired/turbo` and registers stream sources through
AnyCable; importing another Turbo Rails JS client can duplicate that registration.

## Lifecycle and Native References

- [stimulus-pages.md](references/stimulus-pages.md): reactive page access, shared props,
  composition, and connect/disconnect cleanup.
- [native-navigation.md](references/native-navigation.md): native path rules, chrome,
  bottom sheets, external links, back stack, and installed-client compatibility.

## Completion Gate

Verify full-page and fragment routes directly, titles/head assets, URL restoration,
loading/error/empty states, keyboard/focus, private access, and Android presentation.
Use request tests for status/markup/access and browser tests for actual navigation and
lifecycle. State explicitly whether device behavior was exercised.
