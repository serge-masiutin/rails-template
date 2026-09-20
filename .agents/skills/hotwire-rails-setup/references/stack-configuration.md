# Stack Configuration Categories

Use these categories when editing the existing project instructions. This is a checklist
of facts to resolve, not a generated replacement for the complete `AGENTS.md`.

## Rendering and Serialization

Product pages render HTML through Rails/ERB/ViewComponent. Controllers pass explicit
view inputs. JSON endpoints serialize
allowlisted fields with explicit schemas when they have actual non-HTML consumers.
Route architecture work through `hotwire-rails-architecture` and `layered-rails`;
JSON/bridge work through `rails-serialization` and `hotwire-contracts`.

## UI and Assets

Use Tailwind semantic tokens, local Martian Mono, Stimulus/importmap, and ViewComponent.
Route components to `hotwire-ui-components` and catalog work to `lookbook-hub`.
Keep Node/React limited to the existing AgentPrism viewer unless the user changes scope.

## Pagination and Data Loading

Use bounded server queries and stable sort/cursor contracts; lazy frames for noncritical
regions; jobs after commit for long operations; existing AnyCable for updates. Mention a
pagination gem only when manifests confirm it. `hotwire-rails-controllers` covers the
request contract and `hotwire-rails-pages` covers navigation/loading UI.

## Forms and Tests

Use `form_with`, CSRF, 303 success, 422 invalid input, and 400 malformed required shape.
Use Minitest integration/component tests and existing Cuprite browser tests. Route to
`hotwire-rails-forms` and `hotwire-rails-testing`; `docs/testing.md` owns test commands.

## Routing, Access, and Native

Rails helpers generate URLs. Action Policy authorizes actions/scopes; Native User-Agent
changes presentation only. Native contracts live in versioned published JSON and Kotlin/JS
message boundaries; sync bundled copies and keep installed-client compatibility.
Keep authentication, locale, CSRF, and session revocation in their existing boundaries.

## Instruction Update Gate

Every asserted installed dependency, file path, command, and skill name must resolve in
the checkout. Keep user-authored sections. Remove contradictory stale guidance in the
same change; don't append a second block that leaves both policies active.
