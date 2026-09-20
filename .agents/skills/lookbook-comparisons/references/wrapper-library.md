# Preview Composition Recipes

These are contracts/recipes to implement in the existing preview layer when requested,
not claims of installed Ruby classes.

## A/B Canvas

Inputs: two labelled variants, shared content/context, comparison mode (side-by-side,
stacked, or tabs), optional decision link. Hold viewport/data constant so the difference
is the design. Stack at narrow width; tabs must expose selected state and keyboard use.
Keep panels independent without duplicate IDs or a shared dialog target collision.

## State Grid

Inputs: a real component render function/block and labelled meaningful cases. Render
each with explicit overrides and common safe baseline data. Display verified usage counts
optionally; supported unused cases show zero/unused honestly. Keep the grid in the
component's existing preview group, not a new sidebar folder for each state.

## Variant × State Matrix

Use two axes only when both affect output. Labels form row/column headers and each
cell renders the real component. Mark unsupported intersections explicitly rather than
passing invalid inputs or fabricating them. Avoid a full Cartesian matrix of unrelated
props. Respect content width and readable overflow at small viewports.

## Preview Set

Compose a curated set of existing registered previews by stable identity/category.
Validate every reference; a file that exists but is not registered isn't a valid link.
Filter by explicit metadata/category supported in the project, not fictional CSF tags.
Keep set membership derived or owned in one place to prevent stale duplicate lists.

## Ordered Strip

Present an ordered sequence with step labels, action between steps, and links to the
actual full preview. Keep screenshots/embeds at useful width and identify any snapshot
that is not live. The strip is a narrative, not proof that the application performs the
transitions. Include meaningful invalid/empty states when relevant to that story.

## Tracked Decision

Record question, alternatives, status, owner/reviewer when known, date, selected winner,
rationale, evidence, and production destination when shipped. Show pending/chosen/rejected
status visibly; it isn't hidden provenance. Don't fabricate approval or declare a winner
from a screenshot preference. Preserve the record when applying an accepted design.

## Decision Dashboard

Aggregate the same decision records by status/date/topic. Link back to the source
experiment. Show stale pending items without automatically deleting or messaging anyone.
Accepted and shipped are distinct states when implementation remains. Counts derive
from records, not handwritten dashboard totals.

## Shader Canvas

For an explicitly requested shader experiment, use a browser canvas and an isolated
Stimulus/controller module with real WebGL capability checks. Define uniforms, sizing,
pixel ratio bounds, animation clock, pointer input, pause, and reduced-motion behavior.
Compile/link errors must be visible. Stop animation and release GPU resources on
disconnect; don't leak a render loop across Turbo/preview navigation. Use the actual shader API and an explicit canvas controller.

## 3D Canvas

For an explicitly requested 3D experiment, first establish the chosen supported renderer
and isolated asset entrypoint; retain camera, scene, lights, controls, sizing, lazy load,
error, reduced-motion, and cleanup requirements. A React viewer experiment can use
its own compatible runtime after
dependency/API checks; an ERB surface needs an intentionally implemented canvas adapter.

## Motion Stage

Keep repeatable initial/final states, play/pause/replay, duration/easing controls where
useful, and reduced-motion behavior. Prefer existing CSS/Web Animations capabilities.
Cancel animations/listeners on disconnect and restore a clean state for repeated preview
runs. Measure layout shifts and focus/interaction during animation; don't confuse a
forced pseudo-state with a transition test.

## Tokens Canvas

Show actual color, spacing, typography, radius/effect tokens grouped semantically.
Values come from the real CSS/theme source and resolved aliases, not copied design-doc
claims. Use swatches/scales/type samples and readable token names. Keep Martian Mono.
Only display alternate themes that actually exist; do not invent a dark palette.

## Token Matrix

Rows show declared value, resolved mapping/alias, semantic role, adoption, and optional
Figma parity. Link verified consumers through the shared usage map. A base Colors view
does not need every health diagnostic duplicated in every row; expose relevant issues
without replacing the dedicated health view. Include unused and primitive-only tokens.

## Design-System Health

Render kind/severity/message/file/line/fix from verified findings and derive counts.
Separate failed, skipped, and completed checks. Filter by severity/category with accessible
controls; source links must resolve. Do not present absent scanner inputs as a healthy
zero. The view consumes findings; it doesn't shell out from the browser.

## Project Inventory

Show actual stack, design-system adoption, owned live/dead/unresolved components, vendor
primitives, support/scaffold, tokens, orphan previews, and coverage levels. Keep authored
component counts separate from dependency files. Explain method/freshness on demand and
make surprising zeros traceable to evidence.

## Component Usage

Rank real components by verified call sites. Show inputs/used values, parent/child render
relationships, routed pages, and preview coverage. For routed pages, lead with the route
served rather than a misleading zero component-call count. Dynamic expressions are
unknown values, not omitted use. Reuse the inventory/flow map instead of a parallel graph.

## Usage Explorer

Provide token ⇄ component ⇄ page traversal in both directions, search, filters, clear
selection, and source/preview links. Include consumers in vendor primitives and helpers
where relevant. Collapse long alphabetical consumer lists with a truthful count and
expand control. Missing registered preview destinations remain source labels. Distinguish
direct versus transitive use and mark unresolved dynamic edges instead of omitting them.

## Icon Matrix

Inventory actual icon sources/library names, render sites, sizes, and variants. Render
the real icon implementation at the meaningful sizes; distinguish imported from actually
rendered and declared from used. Link “where used” through the shared evidence. Don't
download a new icon library or replace project icons with emoji for the audit.

## App Flow Graph

Render routes/screens, role lanes, action-labelled typed edges, persistent chrome links,
coverage, and unresolved cases. Inputs come from `lookbook-flows`; every edge retains
source evidence. Use actual registered preview links, a legend, keyboard-accessible
details, useful pan/zoom only when warranted, and an equivalent readable list/table.

## Journey Graph

Show one persona's curated sequence with actions and meaningful states, linked to actual
previews/routes. Keep authoring/provenance help collapsed by default while the journey
itself remains readable. Do not treat the graph as an automatically validated user test.
Mobile/narrow layouts should preserve order and labels rather than shrink text illegibly.

## Figma Inventory

Group deliveries by feature/board, show design/spec links, stable node identities,
delivered components/previews, pending parts, and parity/validation status. Merge repeated
deliveries by identity; do not overwrite prior sections. Display prepared versus published
reverse mappings distinctly. All facts come from actual captures and implementation.

## Shared Usage and Provenance Helpers

Put concise evidence near the thing being reviewed. Use a single
preview note/disclosure or support partial with the same data. Show only meaningful
nonzero metadata, keep source/freshness accessible, and avoid duplicate headings/bands.
Experiment status remains visible. Embedded helpers must not impose full-viewport height.
