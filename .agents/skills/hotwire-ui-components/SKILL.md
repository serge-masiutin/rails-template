---
name: hotwire-ui-components
description: ViewComponent and Stimulus UI integration for StarterApp Rails forms, dialogs, sheets, tables, notifications, themes, navigation, and accessible controls.
---

# UI Components for Hotwire Rails

Build reusable UI with ViewComponent, semantic HTML, Tailwind tokens, and small Stimulus
controllers. Use the existing component design before adding another abstraction.

## Component Boundaries

| Responsibility | Implementation |
| --- | --- |
| Component inputs | Explicit ViewComponent constructor inputs and slots |
| Forms | `form_with`, server validation, Turbo processing events |
| Navigation | Rails links/forms and Turbo |
| Local interaction | DOM state, Stimulus targets/values/actions |
| Composition | ERB blocks and component slots preserving semantic elements |
| Page metadata | Rails layout and `content_for` |
| Notifications | Rails flash and `Ui::NoticeComponent` |
| Themes | Explicit CSS token/theme contract |
| Component discovery | ViewComponent conventions and Lookbook previews |

Node/React are used by the AgentPrism viewer. Product components use Rails and Hotwire.

## Setup

Inspect `app/components`, `app/javascript/controllers`, the importmap, application layout,
Tailwind source list, and previews. Reuse the existing `Ui::NoticeComponent` and
`disclosure_controller` where they fit. They do not imply a complete button/dialog/menu
library already exists. New components need real code and registration, not fictional imports.

Use semantic tokens from `app/assets/tailwind/application.css`, fixed supported variants,
and local Martian Mono. A reusable component should expose domain/UI choices such as
variant, size, disabled, label, and content, rather than an unrestricted class override
that silently creates new designs at every call site.

## Inputs in Rails Forms

Keep actual successful form controls: names, IDs, values, booleans, labels, described-by,
autocomplete, and disabled behavior must survive the visual wrapper. Use the Rails
builder instead of hand-assembling a parallel request object.

```erb
<%= form_with model: @user do |form| %>
  <%= form.label :email_address %>
  <%= form.email_field :email_address, autocomplete: "email", required: true,
        aria: { invalid: @user.errors[:email_address].any?, describedby: "email-error" } %>
  <p id="email-error"><%= @user.errors.full_messages_for(:email_address).join(". ") %></p>
  <%= form.submit t("profile.save"), data: { turbo_submits_with: t("forms.saving") } %>
<% end %>
```

Use IDs unique to the form if several editors coexist. The controller validates with
`params.expect`, authorizes, returns 422 with the invalid object or redirects 303 on
success. See `hotwire-rails-forms` for nested/dynamic/wizard/file behavior.

## Dialog with Navigation or a Form

Choose native `<dialog>` when it meets browser/WebView support requirements. Give it
an accessible name, a close/cancel control, and focus behavior. Use `showModal()` for
a modal; setting `open` alone does not provide the same modality.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "trigger"]

  open() {
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
    this.triggerTarget.focus()
  }

  beforeCache() {
    this.dialogTarget.close()
  }
}
```

The example is a controller to implement, not an installed component. Connect
`turbo:before-cache@document` to `beforeCache`; ensure the required targets are present.
Handle native `cancel`/`close` events for the actual product's focus/state contract.
Don't bind a recursive close handler that repeatedly calls itself.

For a URL-addressable editor, render a useful full page at the route and an appropriate
frame when invoked from the dialog. Keep it open on 422. Close/navigate only after
successful save; choose the matching frame/stream/top-level redirect explicitly.
Don't hide failed input by closing the dialog on every `turbo:submit-end` event.

## Table with Server-Side Sorting

Query and authorize in Rails; render rows with stable IDs. Use real links in sortable
headers, preserve allowed filters, reset pagination on sort change, and set `aria-sort`
on the active column. Translate heading text and empty/error states.

```ruby
SORTS = { "name" => :name, "created_at" => :created_at }.freeze

def index
  authorize! User
  sort = params.fetch(:sort, "name")
  column = SORTS.fetch(sort) { raise ActionController::BadRequest, "Invalid sort" }
  @users = authorized_scope(User.all).order(column => :asc).order(:id).limit(50)
end
```

This illustrative index needs the feature's real policy, pagination, and sort directions.
Never interpolate a raw query parameter into SQL. Client sorting only sorts loaded rows;
do not label that behavior as sorting the entire server collection.

## Toast and Flash Messages

Use existing notice/alert flash rendering. Prefer accessible inline feedback unless a
transient toast is a real design requirement. The same status should not be announced
twice through a live region and a second notification system. See
[flash-messages.md](references/flash-messages.md) for redirects, streams, repetition,
stacking, errors, and safe message data.

## Dark Mode

StarterApp currently has semantic tokens but no general theme-switcher contract. Do not
claim a saved user theme or `dark` class behavior already exists. If requested, define
light/dark token values, initial selection (user preference/system), persistence, and
server/browser/native parity. Apply initial theme before painting without violating CSP.
Test contrast, focus, overlays, charts, and Martian Mono in both modes.

Use a small explicit class/data-attribute controller only when needed. Listen to system
preference changes only while the user has not overridden them, and clean up the media
query listener. Validate stored preference against an allowlist; unavailable storage is
a documented optional boundary, not a broad catch around the whole component.

## Page Metadata and Component Lifecycle

Use `content_for :title` and existing layouts. Read
[composition-lifecycle.md](references/composition-lifecycle.md) for current versus
default values, external controls, slots, processing/errors, cleanup, and local state
after navigation.

## Extended Components

Read [components.md](references/components.md) for alert dialogs, sheets, URL tabs,
dropdown actions, pagination, debounced search, checkbox/switch, textarea, date picker,
breadcrumbs, command palette, and loading states. Each recipe defines its server and
accessibility contract.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Input visually changes but submits nothing | Actual name/value and successful-control semantics |
| Form ignores validation | `requestSubmit` versus `submit`, correct controller response |
| Dialog closes on invalid input | Success condition and frame/stream response contract |
| Toast repeats on Back | Temporary snapshot markup and one feedback owner |
| Menu sends destructive GET | `button_to`/form method and CSRF |
| Search runs twice after navigation | Debounce timer/listener cleanup and duplicate controllers |
| Date changes by one day | Date-only string versus UTC instant conversion |
| Theme flashes or leaks between users | Initial theme, validated persistence, logout reset |
| Component differs in Lookbook | Same assets/tokens/typography, realistic inputs, preview scope |

## Verification

Add meaningful previews for materially different states through `lookbook-previews`.
Test form/error/access contracts at the request/component level; use real browser tests
for focus, keyboard, dialog cancel, history, and lifecycle. Check narrow screens and
Native presentation; report device gaps separately. Do not add tests solely for cosmetics.
