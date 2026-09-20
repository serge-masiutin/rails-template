---
name: hotwire-rails-forms
description: 'Full-stack Rails forms for StarterApp: create, edit, delete, nested and multi-step input, uploads, validation, Turbo submission, and Hotwire Native behavior. Use for forms and their server contracts.'
---

# Hotwire Rails Forms

Build forms with Rails, HTML, and Turbo. The
form, its controller, validation, errors, processing state, and successful navigation
are one contract. Stimulus supplies interactions that HTML does not already provide.

## Choose the Form Pattern

| Need | Use | State owner |
| --- | --- | --- |
| Create/edit | `form_with model:` | Active Record or an explicit form object |
| Delete or one-button command | `button_to`, correct HTTP method | Server operation |
| Search/filter | GET `form_with`, named inputs | URL |
| Conditional/dynamic inputs | Rails form + Stimulus targets/actions | DOM until submission |
| Several regions change | Same form + Turbo Stream response | Server-rendered HTML |
| Wizard | Server-owned draft and authorized steps | Persisted draft/session as appropriate |
| Upload | Multipart Rails form; direct upload only when configured | Active Storage + owning record |

Do not install a client form framework for ordinary Rails forms. A frame is optional;
do not add one merely because Turbo is installed. Read `hotwire-rails-architecture`
for state ownership and `layered-rails` when a complex input needs a form object.

## Basic Create Form

Example `Post` models/routes/policies below describe a feature to implement, not existing
StarterApp classes. All labels, errors, notices, and button text need English translation
keys in `config/locales/en.yml`.

```ruby
def new
  @post = Post.new
  authorize! @post
end

def create
  @post = Post.new(post_params)
  authorize! @post

  if @post.save
    redirect_to @post, notice: t("posts.created"), status: :see_other
  else
    render :new, status: :unprocessable_entity
  end
end

private

def post_params
  params.expect(post: [:title, :body])
end
```

```erb
<%= form_with model: @post do |form| %>
  <% if @post.errors.any? %>
    <div id="post-errors" role="alert" tabindex="-1">
      <h2><%= t("forms.errors", count: @post.errors.count) %></h2>
      <ul>
        <% @post.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>
  <%= form.label :title %>
  <%= form.text_field :title, required: true,
        aria: { invalid: @post.errors[:title].any? } %>
  <%= form.label :body %>
  <%= form.text_area :body %>
  <%= form.submit t("posts.save"), data: { turbo_submits_with: t("forms.saving") } %>
<% end %>
```

Use the same invalid object when rendering 422; it carries submitted values and errors.
Populate any select options needed by both `new` and the invalid `create` branch.
Associate per-field messages through `aria-describedby`; use a unique error ID per
form/field. Do not repeat a generic error summary as every field's description.

## Edit Form (Pre-populated)

Load an authorized record, render `form_with model: @post`, and reuse the form partial.
Rails selects PATCH and pre-populates values. Update only permitted attributes. On
failure render `:edit` with 422, including the same layout/frame contract as the initial
form. Never redirect an invalid form and lose its errors/input.

```ruby
def update
  @post = authorized_scope(Post.all).find(params.expect(:id))
  authorize! @post

  if @post.update(post_params)
    redirect_to @post, notice: t("posts.updated"), status: :see_other
  else
    render :edit, status: :unprocessable_entity
  end
end
```

## Delete Form

```erb
<%= button_to t("posts.delete"), post_path(@post), method: :delete,
      form: { data: { turbo_confirm: t("posts.confirm_delete") } } %>
```

Authorize the command and redirect with 303 after success. A GET link must never destroy
records. If a custom confirmation dialog is needed, use the accessible dialog contract
in `hotwire-ui-components`; keep cancel, keyboard focus, and repeated clicks explicit.

## Field Names and Rails Parameters

HTML names define the request shape. Prefer Rails builders; do not pass a flat set of
fields to a controller expecting `post[...]`. Use explicit boolean values and remember
that disabled controls and unchecked raw checkboxes are not successful form controls.
`form.check_box` supplies the usual hidden unchecked value; arrays of nested checkboxes
need special care to avoid unintended records. Validate shape with `params.expect` and
domain values with the model/form object. Missing required shape produces 400, not 422.

## Processing, Errors, Success, and Dirty State

| Form state or action | Implementation | Boundary |
| --- | --- | --- |
| Submission in progress | Turbo disables the submitter; `turbo:submit-start/end` for other UI | Restore additional controls on every completion path |
| Validation errors | `record.errors`, rendered summary and field messages | Server validation remains authoritative |
| Successful submission | Successful response/redirect | Do not infer success merely from a network request completing |
| Temporary success feedback | Rails flash, temporary DOM notice | Avoid replay on restoration visits |
| Unsaved changes | Compare current form values with its initial DOM snapshot | Scope to this form; passwords/files are not persisted |
| Reset input | Native `form.reset()` for defaults; re-render for saved server values | Resetting a field does not erase server errors automatically |
| Default values | Render fresh values after save | Do not overwrite ongoing input on background invalidation |
| Update local errors | Local validation presentation or new server render | Keep local and server validity separate |
| Upload progress | Active Storage direct-upload events when enabled | Ordinary Turbo form submission has no byte-progress API |
| Cancel an operation | Abort an explicit local operation; design submission cancellation | An aborted request does not guarantee rollback on the server |

## Submit Events and External Access

Use declarative Stimulus actions on the form. `turbo:submit-end` includes
`event.detail.success`; redirects and 422 responses still need to be tested through
the resulting DOM. `turbo:before-fetch-response` is lower level and should not become
a second application-wide response router.

An outside submit button can use `form="post-form"`. For a native bridge or dynamic
control, call the real form's `requestSubmit(submitter)` after checking the control's
contract; `form.submit()` bypasses native validation and submit event handling.
Do not call both `requestSubmit()` and a hand-built fetch for the same action.

## Turbo Frames and Streams

Wrap the form and its invalid response in the same `turbo_frame_tag` when using a frame.
Choose success behavior deliberately: render the matching frame, return stream actions,
or navigate the top-level page through a form/link targeted at `_top`. A frame redirect
to a response without its frame is a contract error. Keep stable IDs via `dom_id`.

For same-response stream feedback, use `flash.now`; for redirects use `flash`. The
application layout already renders `Ui::NoticeComponent` with temporary flash markup.
Do not duplicate notices in a separate JS store. See `hotwire-rails-controllers`.

## References

- [advanced-forms.md](references/advanced-forms.md): transforms, nested input, multiple
  forms, conditional submission, reset/dirty state, dynamic fields, wizards, caching,
  and client validation.
- [file-uploads.md](references/file-uploads.md): multipart, multiple attachments, preview,
  direct upload, progress, attachment authorization, and failure handling.
- [stimulus-forms.md](references/stimulus-forms.md): DOM lifecycle, local state, event
  binding, external controls, and uploads.
- [native-forms.md](references/native-forms.md): the same forms in Android WebView and
  optional bridge actions, without treating User-Agent as permission.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| “Content missing” | Matching frame ID in the final response, including 422/authentication |
| Form appears successful but page does not change | Success redirect uses 303 or intentional stream response |
| Values vanish on errors | Render the invalid object and repopulate select options |
| Unknown attributes or 400 | Input names and `params.expect` nesting |
| Checkbox cannot be cleared | Hidden unchecked value, boolean coercion at the boundary |
| Duplicate requests | Multiple submit handlers, `submit` plus fetch, repeated connections |
| Local state leaks after navigation | Controller disconnect and `turbo:before-cache` cleanup |
| Upload errors or image processing in request | Attachment constraints, access, `.variant(...)`, `docs/images.md` |
| Works in desktop only | Keyboard, focus, file picker, frame navigation, native presentation |

## Verification

Cover valid/invalid requests, malformed shape, unauthorized/foreign records, redirects,
and the frame/stream contract when used. Browser-test interactions that request tests
cannot observe: repeated clicks, keyboard confirmation, focus, dynamic inputs, files,
and navigation restoration. Follow `docs/testing.md`; avoid duplicating the same
validation scenario at every layer. A spoofed Native User-Agent is not a device test.
