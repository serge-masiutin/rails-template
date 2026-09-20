# Decision Trees

Use these questions to choose data ownership, state, and navigation for Rails HTML.

## “I need data in my component”

```text
Is this data specific to a page?
├── Yes → authorized controller query, explicit component arguments
│   ├── Needed to understand/use the first screen? → render it initially
│   ├── Noncritical and measurably slow? → separate authorized frame request
│   └── Long-running work? → job after commit, persisted status, private notification
├── Shared navigation/UI? → layout/helper, with explicit access checks
└── External service? → infrastructure boundary called by a model operation/job
    └── Expose JSON only when a real consumer needs a bounded contract
```

Do not turn timing guesses into a universal 100ms/500ms rule. Profile the actual query,
check indexes/N+1, and weigh a second request against useful initial content.

## “I need to update data”

```text
Is this a mutation?
├── Yes → form_with/button_to → params.expect → authorize! → operation
│   ├── Success → 303 redirect (or a deliberately tested Turbo Stream response)
│   └── Validation failure → same form with errors and HTTP 422
└── No
    ├── One region? → frame navigation/reload
    ├── Several regions? → explicit stream targets
    ├── Real-time event? → existing private AnyCable flow
    ├── Search/filter? → GET form with URL params, reset pagination
    └── Optimistic local feedback? → transient UI only; rollback on rejection
```

Do not optimistically commit money, authorization, or an import result in the browser.
Disable duplicate submissions and show pending state without claiming server success.

## “I need state in my component”

```text
Persisted domain fact? → database/model, not a Stimulus value
Bookmarkable state? → URL query/path, validate in Rails
Form values? → named HTML controls; Rails model/form object after submission
Open/closed/focus/preview? → DOM + narrowly scoped Stimulus
Shared by neighboring widgets? → nearest common controller + explicit events/targets
Needs to survive leaving the page? → deliberate draft/history design, with privacy rules
```

Stimulus values have defaults even when attributes are absent; use `hasXValue` to validate
required DOM input once. A missing mandatory value is not an empty domain value.

## “Should I prefetch / poll / defer / use ActionCable?”

```text
PREFETCH
├── A cheap safe GET likely to be visited? → consider Turbo's existing prefetch behavior
├── Sensitive, changing, or costly content? → disable per link/page where needed
└── Mutation? → never use GET/prefetch to perform it

POLL
├── Admin/operations data? → no; use the existing invalidation subscription
├── Domain event available? → private stream and explicit refresh
└── External system with no event channel? → only a justified boundary-specific policy
    with cancellation, visibility handling, timeout, and a named freshness requirement

DEFER
├── Essential defaults/auth/error information? → render initially
├── Hidden section? → lazy frame that loads when visible
├── Immediately useful but independent section? → eager frame
└── Long computation? → job; do not merely move the timeout to another controller

ANYCABLE
├── Change should become visible without a click? → after-commit event
├── Private data? → owner/role check inside the channel and on reload
└── Disconnect/reconnect? → restore a fresh authorized snapshot and preserve valid input
```

An invisible tab should not keep fetching snapshots. Coalesce repeated invalidations,
cancel obsolete requests, and clear private content after access is revoked.

## “I need to navigate”

```text
User follows a read link? → link_to/Rails URL
Local frame action? → matching frame ID
Leave the frame? → data-turbo-frame="_top"
Programmatic visit? → Turbo.visit for a real page transition
Replace current filter history? → data-turbo-action="replace"
External destination? → normal external navigation; validate server-provided URLs
Android modal? → matching versioned path rule, keep an ordinary web destination
```

## “I need to show a notification”

```text
One-time server success/error? → notice/alert and Ui::NoticeComponent
Render without redirect? → flash.now, not a message leaking into the next request
Durable unread notification? → an authorized model/record, not perpetual flash
Local validation/connection state? → scoped live region and translated messages
```

## “I need to redirect after a mutation”

```text
Inside the app? → redirect_to ..., status: :see_other
Invalid form? → render the form, status: :unprocessable_entity
External? → trusted/allowlisted destination, explicit allow_other_host when necessary
           and full-page navigation instead of expecting a matching Turbo Frame
```

Verify the return location for expired sessions: StarterApp only preserves GET/HEAD return
locations. Do not replay a previous mutation after sign-in.
