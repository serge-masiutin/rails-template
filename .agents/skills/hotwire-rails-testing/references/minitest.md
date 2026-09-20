# Minitest Examples

These examples use hypothetical posts/routes/fixtures. Copy the assertion pattern into
the actual feature's test, using its real login helper and authorization setup.

## Success, Flash, and Invalid Input

```ruby
test "creates a post and shows the destination notice" do
  assert_difference "Post.count", 1 do
    post posts_path, params: { post: { title: "Example", body: "Text" } }
  end
  assert_response :see_other
  assert_redirected_to post_path(Post.order(:id).last)
  follow_redirect!
  assert_response :success
  assert_select "#flash [role=status]", text: I18n.t("posts.created")
end

test "renders invalid input without losing entered values" do
  assert_no_difference "Post.count" do
    post posts_path, params: { post: { title: "", body: "Keep this text" } }
  end
  assert_response :unprocessable_entity
  assert_select "[role=alert]"
  assert_select 'textarea[name="post[body]"]', text: "Keep this text"
end
```

Prefer asserting against a record identified by the feature's response/known attributes
when concurrent creation is relevant; `Post.order(:id).last` here is only an isolated
fixture-test example. Test missing `post` shape separately when changing parameter handling.

## Frame Contract

```ruby
get edit_post_path(post_record), headers: { "Turbo-Frame" => "post-editor" }
assert_response :success
assert_select 'turbo-frame[id="post-editor"]' do
  assert_select 'form[action=?]', post_path(post_record)
end
```

Repeat the real invalid submission with the frame header and assert the same ID on 422.
Test the full route without the header too. Don't assert that a frame exists somewhere
while overlooking that the response's expected frame is missing.

## Stream Contract

```ruby
patch post_path(post_record),
  params: { post: { title: "Updated" } },
  headers: { "Accept" => "text/vnd.turbo-stream.html" }
assert_response :success
assert_equal "text/vnd.turbo-stream.html", response.media_type
assert_select 'turbo-stream[action="replace"][target=?]', dom_id(post_record) do
  assert_select "template", text: /Updated/
end
```

Include `ActionView::RecordIdentifier` if the test context does not already provide
`dom_id`. Match the actual application's selected action (`replace` versus `update`),
not this example blindly. Use browser coverage for actual client application of streams.

## Deferred Region

Request the parent page and assert its `turbo-frame` has the expected `src` and loading
placeholder. Request the source endpoint separately and assert authorized content.
Use a query/operation boundary assertion only when needed to prove the slow operation
is absent from the initial load; don't stub every Active Record chain.

## Component Rendering

Follow existing `ViewComponent::TestCase` or project integration helpers. Render real
component inputs and assert role/text/links/variant behavior relevant to its contract.
Test unknown variants only if rejection is part of the public interface. A Lookbook
preview demonstrates a state; it does not replace a behavior test.

## Missing Data and Access

Exercise nonexistent and foreign IDs with the project's intended 404/403 behavior.
For JSON boundaries test exact allowlisted keys and malformed input; for HTML assert
secrets/private values are absent where exposure is plausible. Don't seed real PII into
fixtures or copy production traces into snapshots.
