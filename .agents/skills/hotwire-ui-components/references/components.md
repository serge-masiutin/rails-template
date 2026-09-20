# Extended UI Component Recipes

## Alert Dialog with a Server Action

Keep the destructive operation in an authorized Rails form. The confirmation UI names
the affected object and consequence, provides a safe cancel, and sends no request until
confirmed. Simple cases use `data-turbo-confirm`; richer cases use an accessible dialog.
Preserve the original submitter intent and prevent repeated confirmation/submission.
On failure, show the error without falsely removing the record. On success, redirect
303 or apply the intended stream and place focus on a sensible surviving element.

```erb
<%= button_to t("users.delete"), user_path(user), method: :delete,
      form: { data: { turbo_confirm: t("users.confirm_delete", name: user.name) } } %>
```

This example needs actual routes/translations/policy. Interpolated user text stays escaped.
Do not use `html_safe` to make a confirmation message appear formatted.

## Sheet / Slide-over Panel

A browser sheet is usually a dialog with different visual placement. Reuse the same
focus, Escape, cancel, processing, and invalid-form contracts. Keep close controls inside
the visible area on a narrow screen/soft keyboard. Restore document scroll locks on
every close and disconnect path. A Native bottom sheet is a separate destination selected
by versioned path rules; don't emulate that back stack through a CSS-only browser sheet.

For form success, decide whether to replace the sheet content, close it and update a
record, or navigate the full page. Invalid 422 keeps the entered values and sheet open.
Direct access to the editor route must still work without an already-open parent page.

## Tabs with URL State

When tabs are navigation, use links with a current-state indicator and server-validated
tab names. Preserve allowed query parameters. A tab can target a frame and promote its
navigation to history with `data-turbo-action` where required. Direct reload renders the
selected tab. Expensive inactive content can be a lazy frame; its endpoint still authorizes.

For genuinely local tab panels, implement the tablist/tab/tabpanel keyboard pattern,
selected state, roving focus, and labelled relationships. Don't assign ARIA tab roles
to ordinary navigation links unless implementing their keyboard behavior too.

## Dropdown Menu with Actions

Use a disclosure containing ordinary links/buttons unless an application-menu keyboard
pattern is needed. Existing `disclosure_controller` toggles `aria-expanded` and hidden
content; its required targets are `button` and `content`.

```erb
<div data-controller="disclosure">
  <button type="button" aria-expanded="false" aria-controls="user-actions"
          data-disclosure-target="button" data-action="disclosure#toggle">
    <%= t("users.actions") %>
  </button>
  <div id="user-actions" hidden data-disclosure-target="content">
    <%= link_to t("users.edit"), edit_user_path(user) %>
    <%= button_to t("users.delete"), user_path(user), method: :delete %>
  </div>
</div>
```

Make IDs unique for each rendered row. Add closing/Escape/outside-click behavior only
when the intended interaction needs it, with cleanup and focus tests. A `role="menu"`
requires arrow-key/roving-focus semantics; it is not just a styling hook.

## Pagination

Render Previous/Next and numbered links only when the query contract supports them.
Use `aria-current="page"`, a labelled navigation region, and noninteractive unavailable
states. Preserve filters/sort, use a stable ordering, bound page/cursor input, and avoid
pretending a cursor API knows the total page count when it does not.

Frame pagination must return the matching frame. Progressive loading additionally
handles pending, duplicate rows, end, failure/retry, and changing filters mid-request.
Keep a manual link/button available where auto-loading is optional.

## Search Input with Debounce

Start with a working GET form and explicit submit button. An optional controller can
delay `requestSubmit`; clear its timer on disconnect and don't submit during IME
composition. Keep the query in the URL when the user must bookmark/share results.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  search(event) {
    clearTimeout(this.timeout)
    if (event.isComposing) return
    this.timeout = setTimeout(() => this.element.requestSubmit(), 300)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
```

Attach this example to the form and wire the search field's input event; choose a
controller name and complete registration. Handle compositionend if the target browsers
do not issue the final non-composing input event. Preserve focus/selection in the actual
frame layout, and test stale queries rather than adding a second competing fetch path.

## Checkbox and Switch

Use a real checkbox for a boolean, an explicit label, and a submitted unchecked value.
Rails `form.check_box` provides a hidden unchecked value. A switch can be a styled
checkbox with the appropriate role, but still needs name/value, keyboard, and disabled
semantics. Server-side boolean casting/validation defines the accepted values.
For tri-state input, explicitly model the third state; don't let “indeterminate” become
an accidental missing parameter. Nested array checkboxes need a deliberate request shape.

## Textarea

Use `form.text_area` and preserve submitted text on 422. Keep a visible label, useful
rows/minimum size, and translated hint/error associations. Optional autoresize belongs
in a small controller with a bounded height; it must not prevent manual resize or
destroy cursor/selection on every input. Render text escaped when displaying it later.

## Date Picker

Prefer a native date input when it meets the product need. Date-only values use
`YYYY-MM-DD` and a Rails Date contract; don't convert them through UTC timestamps and
shift a day. Datetimes need an explicit timezone and instant/local-time policy.

```erb
<%= form.label :due_on %>
<%= form.date_field :due_on %>
```

A custom calendar needs a keyboard-accessible trigger/grid, selected/min/max/disabled
states, a named submitted value, clear action, and error handling. Keep its display
format separate from the serialized value. Use Rails `l`/translations and the existing
locale allowlist. Test leap dates, clearing, boundaries, and timezone edges for instants.

## Breadcrumbs

Render semantic navigation with a translated accessible label. Earlier items are real
Rails links; the current item uses `aria-current="page"` and need not be a link.
Separators are decorative and hidden from assistive technology. Escape user-provided
names and validate any externally sourced URL before rendering it as a destination.

## Command Palette

Treat it as a dialog with searchable actions/navigation. Read actions remain links;
commands remain authorized forms. If suggestions are remote, use a bounded authorized
endpoint, debounce/cancel, and ignore stale responses. A local filter cannot search
records not loaded into the page. Implement keyboard selection, labelled input/results,
empty/loading/error states, Escape, focus restore, and a documented shortcut that does
not fire while typing in another input. Clean up global shortcut listeners.

## Loading and Empty States

Distinguish no records, no search matches, initial loading, mutation processing, and
failure. Skeletons should reflect actual layout without inventing content; mark decorative
pieces appropriately and provide a status message where needed. Avoid hiding the last
useful authorized content while a background refresh is pending. Clear private content
on access loss according to the operational-page contract.
