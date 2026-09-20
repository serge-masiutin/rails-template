# Architecture Rules — Expanded Reference

Read the rule relevant to the feature and its matching tests. The examples use an
illustrative `Post` owned by a user; create the actual domain model, policy, translations,
routes, and fixtures together when implementing such a feature. No example authorizes
adding a new product feature merely to exercise a skill.

## Rule 1: Server Owns Data (CRITICAL)

Render authorized records in the initial response. Load associations before rendering and
pass records or explicit values into components. Do not fetch the same list again when
a Stimulus controller connects.

```ruby
class PostsController < ApplicationController
  def index
    authorize! Post
    @posts = authorized_scope(Post.all).includes(:author).order(created_at: :desc, id: :desc)
  end
end
```

`authorized_scope` requires the corresponding Action Policy scope; define and test it.
Do not treat an unscoped `Post.all` as safe because the current page only links to owned
records. Pagination belongs in the query, not a JavaScript array slice.

```erb
<section aria-labelledby="posts-heading">
  <h1 id="posts-heading"><%= t("posts.index.heading") %></h1>
  <%= render @posts %>
</section>
```

When the view needs computed presentation values, add a focused presenter/component.
When multiple screens need the same query, consider a model query object. Keep business
operations out of presenters and templates.

Verify that increasing the number of posts does not increase association queries linearly.
Test empty and populated HTML at the HTTP/component layer before adding a browser test.

## Rule 2: Server Owns Auth (CRITICAL)

StarterApp includes `Authentication`, `Localization`, Action Policy authorization context,
and `verify_authorized` in `ApplicationController`. Reuse them; do not build a parallel
authentication helper for Native or an endpoint described as “just a frame”.

```ruby
def edit
  @post = authorized_scope(Post.all).find(params.expect(:id))
  authorize! @post
end
```

The exact scope/policy must match the use case. A controller may intentionally find a
record and return 403 rather than hide it with 404; keep that decision consistent and
test guest, owner, other user, administrator, and revoked access where applicable.

```erb
<% if allowed_to?(:edit?, post) %>
  <%= link_to t("posts.edit.link"), edit_post_path(post) %>
<% end %>
```

This hides an unavailable action, but the action must independently authorize the request.
The Android User-Agent only changes presentation. Private streams check access again in
the channel, and queued work checks the current permission rather than trusting an old page.

## Rule 3: Use Rails Forms (CRITICAL)

Keep values in named inputs and errors on the model/form object. Rails builds authenticity
tokens, method overrides, checkbox hidden values, nested names, and persisted values.

```erb
<%= form_with model: post do |form| %>
  <%= form.label :title %>
  <%= form.text_field :title, required: true,
        aria: { invalid: post.errors[:title].any?, describedby: "post-title-errors" } %>
  <div id="post-title-errors">
    <% post.errors.full_messages_for(:title).each do |message| %>
      <p><%= message %></p>
    <% end %>
  </div>
  <%= form.submit t("posts.form.save"), data: { turbo_submits_with: t("posts.form.saving") } %>
<% end %>
```

```ruby
def update
  @post = authorized_scope(Post.all).find(params.expect(:id))
  authorize! @post
  if @post.update(params.expect(post: [ :title, :body ]))
    redirect_to @post, status: :see_other, notice: t("posts.updated")
  else
    render :edit, status: :unprocessable_entity
  end
end
```

Required parameter shape errors are 400, semantic validation errors 422, and a successful
mutation normally redirects with 303. Do not serialize errors into flash and discard the
invalid model. For several forms, scope each model and error region separately.

## Rule 4: Navigation (HIGH)

Use Rails route helpers so locale and future route changes stay centralized. A real link
works with keyboard navigation, open-in-new-tab, Turbo Drive, and the Native navigator.

```erb
<%= link_to t("posts.index.heading"), posts_path %>
<%= button_to t("posts.destroy.action"), post_path(post), method: :delete,
      form: { data: { turbo_confirm: t("posts.destroy.confirm") } } %>
```

A frame captures navigation within its region. Use `_top` for a full-page destination;
respond with the same frame ID for a regional action. An authentication destination that
must escape frames can use `turbo_page_requires_reload` in its head content.

For an external flow, use normal browser navigation with a trusted destination. Disable
Turbo on the initiating form when the protocol requires a full page handoff. Never blindly
allow an arbitrary return URL supplied by params. Android needs a tested external-navigation
policy and HTTPS in release; do not infer it from desktop behavior.

## Rule 5: Data Refresh (HIGH)

Choose the smallest HTML boundary matching the feature. A frame handles a region; a stream
can replace a row, count, and flash in one response. Stable `dom_id` values are part of the
contract and must remain unique on the page.

```erb
<%= turbo_frame_tag "posts", src: posts_path do %>
  <p role="status"><%= t("posts.loading") %></p>
<% end %>
```

The endpoint renders a matching `turbo_frame_tag "posts"`; it does not repeat `src` and
recursively load itself. The request still authenticates and authorizes the collection.

```erb
<%= turbo_stream.replace dom_id(@post), partial: "posts/post", locals: { post: @post } %>
```

Do not wrap every stream target in a frame. A normal element with a stable ID is sufficient
when no regional navigation is needed. Use `replace` when the root changes; `update` when
retaining the target element and its controller is intentional.

For server events, use existing AnyCable integration. Broadcast only after commit. Admin
panels receive invalidation, then perform a fresh role-checked request. Reuse the cancellation,
coalescing, hidden-tab, and error-state behavior already in `app/javascript/live_updates.js`.

## Rule 6: Global Data (HIGH)

The application layout already knows its navigation, locale, typography, and signed-in
presentation. Keep only that presentation knowledge there. Model operations must not read
`Current.user` or the request implicitly: pass the actor or permitted record explicitly.

For small JS configuration, render escaped data attributes with a documented shape.

```erb
<div data-controller="disclosure">
  <button type="button" data-action="disclosure#toggle"
          data-disclosure-target="button" aria-expanded="false">
    <%= t("details.toggle") %>
  </button>
  <div data-disclosure-target="content" hidden><%= content %></div>
</div>
```

This uses the existing disclosure controller's `button` and `content` targets. It reads
the expanded state from the button; no additional `open` Stimulus value is needed.
Use `data-*` JSON only for values the browser really needs; never dump a user record or secrets.

## Rule 7: Flash Messages (HIGH)

The current layout renders notice/alert through `Ui::NoticeComponent` and marks the flash
container `data-turbo-temporary`. Keep this integration instead of adding a toast framework.

```ruby
redirect_to account_path, status: :see_other, notice: t("accounts.saved")
```

```ruby
flash.now[:alert] = t("posts.invalid")
render :edit, status: :unprocessable_entity
```

Use `flash.now` for the response being rendered. Do not replay flash after browser back,
frame reload, or broadcast refresh. New flash keys require a defined component variant and
tests; `Ui::NoticeComponent` deliberately fails on an unsupported variant.

Persisted notifications have their own model and read-state contract. They are not flash
with an arbitrarily extended lifetime. Translate complete messages through Rails i18n.

## Rule 8: Expensive Queries (MEDIUM)

Measure before splitting the request. Fix missing eager loading/indexes before hiding a
slow query behind a skeleton. Separate requests help when the page has useful independent
content to show first.

```erb
<%= turbo_frame_tag "analytics", src: analytics_path, loading: :lazy do %>
  <p role="status"><%= t("analytics.loading") %></p>
<% end %>
```

`loading: :lazy` waits until visible; omit it when the panel should load immediately.
The endpoint must render the same ID, an accessible empty state, and a recoverable failure
state. A long model generation/import belongs in an `ApplicationJob` after commit, with
persisted progress/result and explicit access checks when loading or delivering it.

Group data that belongs to one region into one request. Do not add a frame per individual
counter and turn one query into a burst of HTTP requests. Test the frame request directly,
then test lazy visibility only if the feature depends on that behavior.

## Rule 9: Persistent Layouts (MEDIUM)

Rails layouts are shared markup; they do not automatically preserve DOM nodes between
visits. Turbo snapshots and permanent elements solve different problems.

```erb
<div id="ongoing-player" data-turbo-permanent>
  <audio controls></audio>
</div>
```

Use a permanent element only if its state should survive visits and the same ID appears
in both documents. Do not make account identity, permissions, or private content permanent.
At `turbo:before-cache`, return transient widgets to a restorable state. Clean up listeners,
observers, pending requests, object URLs, and timers when their owner disconnects.

Check back/forward restoration, frame replacement, and reconnect, not just an initial full
load. Native modal/back behavior additionally comes from versioned path configuration.

## Rule 10: Components as Renderers (MEDIUM)

A ViewComponent receives its inputs explicitly, validates a finite variant map, and renders
HTML. It must not query for the current user, enqueue jobs, mutate records, or call a service.

```ruby
class Ui::StatusComponent < ApplicationComponent
  VARIANTS = { normal: "text-ink", warning: "text-danger" }.freeze

  def initialize(label:, variant:)
    @label = label
    @classes = VARIANTS.fetch(variant)
  end
end
```

```erb
<span class="<%= @classes %>"><%= @label %></span>
```

Translate labels at the owning presentation boundary; do not use `html_safe` for user text.
Document material variants in Lookbook, test semantic DOM with ViewComponent/Minitest, and
reserve Cuprite for behavior depending on Turbo or JavaScript. A catalog preview must render
the actual component, not an independently recreated version of its markup.
