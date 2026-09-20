# Authorization in HTML, Frames, Streams, and JSON

## Controller Pattern

StarterApp supplies the actor to Action Policy through `ApplicationController`. Use the
existing authentication concern and `authorize!`; keep `verify_authorized` active.

```ruby
def edit
  @post = authorized_scope(Post.all).find(params.expect(:id))
  authorize! @post
end
```

The model/policy scope must be implemented for the feature. Scoping prevents collection
leaks; action authorization enforces the attempted operation. Neither replaces the other.
Do not skip authorization on a frame endpoint because its parent page was authorized.

## Template and Component Pattern

```erb
<article id="<%= dom_id(post) %>">
  <h2><%= post.title %></h2>
  <% if allowed_to?(:edit?, post) %>
    <%= link_to t("posts.edit.link"), edit_post_path(post) %>
  <% end %>
  <% if allowed_to?(:destroy?, post) %>
    <%= button_to t("posts.destroy.action"), post_path(post), method: :delete %>
  <% end %>
</article>
```

For a reusable component, pass an explicit `can_edit:`/`can_destroy:` presentation input
if that is its public API. Do not pass a controller into a domain object or query for the
current user in the component. User text stays escaped.

## Key Rules

1. Check the current actor and operation on every HTTP action.
2. Scope collections before rendering/counting/paginating; avoid leaking counts.
3. Authorize a private subscription in the channel and refresh data after revocation.
4. Jobs receive IDs, reload records, and check current access before generating/delivering.
5. User-Agent and a browser-provided `can` value never grant access.
6. Keep `/admin` under `Admin::BaseController` and the shared admin policy.
7. Keep Basic/Bearer machine endpoints separate from browser session access.
8. Return the established 401/403/redirect shape for the particular endpoint; do not turn
   access failure into an empty successful collection.

Test guest, allowed actor, another owner, and role revocation where the feature supports
roles. An element being hidden in a preview is not an authorization test.
