---
name: hotwire-rails-controllers
description: 'Rails controllers for StarterApp HTML, Turbo Frames and Streams: explicit inputs, authorization, lazy regions, flash, 303/422 responses, external redirects, caching, and browser/Native compatibility.'
---

# Hotwire Rails Controllers

Server-side patterns for Rails controllers serving the shared web/Android HTML interface.
Use Rails templates, Turbo Frames, and Streams with explicit data-loading boundaries.

Before adding a query or response region, ask:

- **Needed in the first response?** Render it in the normal HTML template.
- **Shared navigation information?** Use the existing layout/helper, not a global JSON blob.
- **Optional section?** Give it an authorized URL and load its frame when requested.
- **Expensive independent section?** Measure it; use eager/lazy frame loading if appropriate.
- **Long operation?** Run a job after commit and render persisted progress/result.
- **Rarely changing reference data?** Render normally; add caching only for measured benefit
  and with a cache key/invalidation policy that respects identity, locale, and permissions.

Never:

- Skip `authorize!` because a request comes from a frame, stream, WebView, or hidden UI.
- Use a GET action for a mutation or return a successful form page with 200 after POST.
- Redirect an invalid form while losing the invalid object and field errors.
- Treat `Turbo-Frame` or `Accept` headers as permission to expose data.
- Serialize Active Record wholesale to the browser; render HTML or an explicit JSON contract.
- Swallow query/contract failures into empty success states.

## Render Syntax

Pass explicit view inputs to Rails templates and components.

| Situation | Response | Location |
| --- | --- | --- |
| Page with data | Query + normal/explicit template render | `app/views/<controller>/<action>.html.erb` |
| Static page | Authorized empty action + template | Same convention |
| Different page | `render "errors/show", status: ...` | Explicit template |
| Frame response | HTML containing the requested stable frame ID | Same template or focused partial/template |
| Several DOM updates | `format.turbo_stream` with a template | `<action>.turbo_stream.erb` |
| API consumer | `render json:` with an explicit allowlist | `rails-serialization` contract |

The following examples assume a newly implemented `Post` domain with its own Action Policy
scope, routes, translations, and fixtures; those are prerequisites, not existing app classes.

```ruby
class PostsController < ApplicationController
  def index
    authorize! Post
    @posts = authorized_scope(Post.all).order(created_at: :desc, id: :desc)
  end

  def show
    @post = authorized_scope(Post.all).find(params.expect(:id))
    authorize! @post
  end
end
```

Use model namespaces for complex operations and query objects for reusable complex queries.
The HTTP action owns parameter parsing, access checks, dispatch, response status, and format.
Do not move request/`Current` objects into a domain operation just to shorten the action.

## Data Loading Modes

| Data requirement | Mechanism | Evaluation |
| --- | --- | --- |
| Regular data | Query + normal template | During the page request |
| Lazy query | A focused endpoint/region | Only when that action executes |
| Optional data | Link/action exposing a frame | On the explicit request |
| Deferred data | Frame with `src` | Separate request after initial HTML |
| Grouped deferred data | One frame endpoint owning related values | One request for the region |
| Reference data loaded once | Server-rendered data; deliberate cache when justified | Defined by the server cache policy |
| Append/prepend | Turbo Stream operation on a stable collection target | When an authorized response/event arrives |
| Update matching record | Replace/update a stable `dom_id` | Explicit element replacement |
| Deep/nested update | Several explicit stream targets or replace their owner | No implicit recursive object merge |
| Always-fresh security/context | Recheck on every protected HTTP/WS request | Never inherited from a stale page |
| Infinite scroll | Bounded server query + next page link/frame | Incremental requests with stable ordering |

Read
[data-loading.md](references/data-loading.md) before combining pagination, append, lazy
loading, or refresh. A basic initial page does not need that entire reference.

### Deferred Regions — Full Stack Example

```erb
<h1><%= t("dashboard.heading") %></h1>
<%= render Ui::SummaryComponent.new(summary: @summary) %>
<%= turbo_frame_tag "analytics", src: analytics_path do %>
  <p role="status"><%= t("analytics.loading") %></p>
<% end %>
```

The separate action authenticates/authorizes again and queries only that region.

```ruby
def show
  authorize! :analytics, to: :show?
  @analytics = Analytics::Summary.new(actor: Current.user).call
end
```

```erb
<%= turbo_frame_tag "analytics" do %>
  <%= render Ui::AnalyticsComponent.new(summary: @analytics) %>
<% end %>
```

Implement the named policy, query, and components in the feature being built. Do not copy
these names into StarterApp and report them as existing integration points. For long work,
render persisted job state here instead of blocking the frame request until it completes.

## Shared Data

Keep shared presentation in the layout and its helpers/partials. StarterApp already has the
authenticated navigation, locale, typography, flash container, and private user stream.
Do not add an initializer that reads request-local state, a global JavaScript user object,
or a mutable class attribute holding the current user.

When a component needs permissions, compute presentation predicates through Action Policy
and pass only the values required for rendering. Domain operations receive the actor
explicitly. Small JS contracts use escaped data attributes and are checked once on connect.

Inheritance should remain clear: `Admin::BaseController` adds role authorization and
cache restrictions for `/admin`; machine health/metrics retain their separate contracts.
Do not widen a child controller's data exposure by merging an unreviewed “shared props” hash.

## Flash Messages

StarterApp uses `notice` and `alert`. The layout renders `Ui::NoticeComponent`; its finite
variant map deliberately rejects unsupported keys.

```ruby
redirect_to account_path, status: :see_other, notice: t("accounts.saved")
```

```ruby
flash.now[:alert] = t("posts.invalid")
render :edit, status: :unprocessable_entity
```

Use `flash.now` when rendering this response. Flash must not repeat on back/forward or
regional refresh; preserve `data-turbo-temporary`. A durable notification belongs in a
record with its own read-state contract. Add a new flash key only with UI support and tests.

## Redirects and Validation Errors

Post/Redirect/Get success uses 303. Invalid data re-renders the submitted form with 422,
the same object, its input values, and accessible errors. Invalid parameter structure is 400.

```ruby
def update
  @post = authorized_scope(Post.all).find(params.expect(:id))
  authorize! @post
  if @post.update(params.expect(post: [ :title, :body, :published ]))
    redirect_to @post, status: :see_other, notice: t("posts.updated")
  else
    render :edit, status: :unprocessable_entity
  end
end
```

HTML can use `errors.full_messages` for a summary and `full_messages_for(:title)` next to
the field. For JSON endpoints preserve field keys through the declared schema.

For a Turbo Frame edit, both edit and error responses contain the same frame ID. On success,
choose a matching regional destination or an explicit top-level visit. Do not return
unrelated HTML and suppress `turbo:frame-missing` to hide the mismatch.

An intentional Turbo Stream mutation response may return 200 and replace several targets;
provide a normal HTML 303 path as appropriate and test both. Do not change every existing
StarterApp mutation from its documented 303 contract without a feature requirement.

## Authorization in HTML

Visibility and enforcement are separate. Read [authorization.md](references/authorization.md)
when adding policy-aware controls, a private frame, a JSON response, or a subscription.
The reference covers the full controller/template pattern, scopes, and revoked access.

```erb
<% if allowed_to?(:update?, post) %>
  <%= link_to t("posts.edit.link"), edit_post_path(post) %>
<% end %>
```

Never copy an authorization predicate from the browser into the next request as proof.

## External Redirects

Use normal Rails external redirects only for a trusted/allowlisted destination. An external
flow uses full-page navigation.

```ruby
redirect_to checkout_url, status: :see_other, allow_other_host: true
```

`checkout_url` here must come from a validated integration boundary, not arbitrary params.
For OAuth/payment forms requiring a browser handoff, disable Turbo on that initiating form
and test the return path. Keep provider network calls out of a database transaction.
On Android, validate the browser/app navigation behavior separately from the Rails redirect.

## Browser History and Sensitive Content

Turbo caches DOM snapshots; it does not encrypt a JSON history envelope. For sensitive
pages use the appropriate Turbo cache-control policy and HTTP `Cache-Control`; they serve
different layers. Admin pages retain `no-store`. On logout/role revocation, clear displayed
private content and revoke subscriptions; a browser back button must not resurrect access.

Read [configuration.md](references/configuration.md) for cache policy, assets, locale,
error handling, and server-rendered layouts. Do not invent an encryption toggle as a substitute
for current authentication and cache tests.

## Configuration

Use the existing `config/application.rb`, environment settings, importmap, layouts, and
typed `app/configs` classes. There is no new Hotwire initializer required per controller.
Read configuration details only for setup or a diagnosed integration problem.

## Troubleshooting

| Symptom | Likely boundary | Check/fix |
| --- | --- | --- |
| Content missing in a frame | Wrong/missing ID | Compare request header and response frame ID |
| Successful POST renders a form page | Wrong status/response | Return the intended 303 or tested stream response |
| Validation loses values | Redirect/recreated object | Render the invalid object with 422 |
| Input has no matching error | Field name/error ownership | Use the correct model and accessible field IDs |
| External redirect stays in a frame | Navigation scope | Full-page handoff and trusted destination |
| User sees another user's data | Query/cache/stream scope | Fix server authorization and cache keys; add regression test |
| Flash appears again after back | Snapshot lifecycle | Preserve temporary flash and avoid duplicating client notifications |
| Locale leaks between requests | Global locale mutation | Use the existing `Localization`/`I18n.with_locale` boundary |
| More records cause more SQL | Rendering queries/N+1 | Preload and test on growing collections |

## Related Skills and References

- Form values and errors → `hotwire-rails-forms`.
- Page/frame navigation → `hotwire-rails-pages`.
- UI feedback and controls → `hotwire-ui-components`.
- JSON/type contracts → `rails-serialization` + `hotwire-contracts`.
- Integration/browser coverage → `hotwire-rails-testing`.
- Advanced loading → [data-loading.md](references/data-loading.md).
- Access → [authorization.md](references/authorization.md).
- Setup/history/cache/errors → [configuration.md](references/configuration.md).
