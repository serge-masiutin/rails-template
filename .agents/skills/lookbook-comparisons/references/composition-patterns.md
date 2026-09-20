# Composition Patterns

## A/B Design Decision

Wrap two real implementations in one labelled comparison with identical data and width.
Put the decision question/status outside the panels; keep provenance/source links in a
small disclosure. If comparing motion, coordinate only the start signal, not hidden
shared mutable state. Record the accepted option before graduation.

## Role Comparison

Use verified role-dependent inputs to show public/user/admin presentation. Label simulated
preview context clearly; it is not an authorization test. Avoid setting global Current
for the entire catalog. Request tests separately confirm endpoints reject forbidden access.

## Status Grid

Render the same real component in loading, empty, populated, error, disabled, or other
material supported states. Keep a small shared factory for repeated shape. Preserve
unique IDs and event scope when several interactive instances render on one canvas.

## Page Composition

Render real page components/partials with explicit safe input. Choose full-width layout
and inspect desktop/narrow viewport. Identify any adapter/mock context; don't call a
static facsimile a real page capture. Shared chrome can be composed once around the page,
but don't duplicate the application layout inside an iframe's document.

## Motion / Canvas Composition

Keep canvas dimensions and background at the wrapper boundary. An embedded stage should
fit its panel instead of demanding `100vh`. Use visible play/pause/replay and reduced
motion. Clean up animation, observers, listeners, and GPU resources on disconnect.
Optional heavy renderers load only for the requested experiment; don't add them to every
preview or the product application entrypoint.

## Layering

Decision → A/B → state or motion stage → actual component is a useful composition when
each layer has one responsibility. Stop when another wrapper merely adds labels/spacing
already owned by its parent. Verify keyboard order, overlay containment, nested scroll,
unique IDs, token background, and responsive readability in the rendered result.
