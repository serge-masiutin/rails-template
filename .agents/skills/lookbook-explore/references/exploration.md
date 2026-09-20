# Exploration Workflow

## Isolate the Experiment

Choose a preview-only directory in the established test tree, a clear class namespace,
and explicit load/discovery behavior. Don't add experiment paths to production autoload
or let production code render them. Keep a copy of the current accepted component as
a comparison only when needed; don't fork its public API prematurely.

## Design the Comparison

Hold content/viewport/tokens constant while changing the intended variable. Compare
side-by-side when width allows, stacked on mobile, or with clearly labelled tabs when
space is constrained. Separate role differences from style alternatives. Keep the
decision prompt and draft state visible, with source links accessible on demand.

## Figma Input

Capture actual variable definitions, component context, and structure through available
tools/exports. Record file/node/source/freshness and truncation. Use screenshots for
visual comparison, not guessed exact tokens. If only an image is available, label the
work as visual approximation and keep unsupported dimensions/behaviors explicit.
Don't upload/publish mappings just because a Figma URL was provided for reading.

## Iterate

Use real component inputs and representative loading/error/empty/long-content cases.
Keep local interaction cleanup and accessibility intact; a sandbox should not hide
keyboard or lifecycle defects. Avoid external network calls and production data.
Record why a variant changed so the accepted option has a traceable decision basis.

## Graduation

Check stable inputs/slots, concrete consumers, accepted visual/interaction design, and
token adoption. Verify the relevant preview/browser behavior. If one criterion is not
met, name it and continue the experiment; don't silently mark it production-ready.
When accepted, pass component paths, selected variant, API, consumers, checks, and decision
evidence to `lookbook-ship` within the same task when already authorized.
