# Preview Authoring Patterns

## State Extraction

Read constructor defaults/validation, variant maps, slots, template branches, Stimulus
targets/actions/values, and callers. Group by material output or behavior: empty versus
populated, loading versus ready/error, enabled versus disabled, selected/current, role-
dependent affordance, long content, narrow width, and real variant differences.

Choose representative intersections. A “danger + disabled + long label” example is useful
only if that combination reveals behavior not already covered. Don't multiply every
size by every color by every state. Keep declared-but-unused cases visible but honest.

## Factories and Input Shapes

For three or more examples sharing a nested input shape, write one small preview factory
with explicit keyword overrides. Use domain-realistic translated text and deterministic
safe values. Don't duplicate a huge mock object in each preview or use production records
whose state changes over time. Reject missing required fields rather than hiding them
with deep defaults. Factory ownership stays in preview/test support.

## Controls

Inspect installed Lookbook `@param` annotation syntax and supported input types before
adding controls. Expose finite variants as selects, booleans as toggles, numeric bounds
where applicable, and safe text inputs. Don't expose model instances, arbitrary constant
names, callables, or secrets as editable query parameters. Validate constructor enums.

Render-only reports and fixed regression examples can omit controls. A visible control
that doesn't change the component is misleading; exercise it in the actual catalog.
Keep parameter descriptions near the preview, not duplicated in a separate source of truth.

## Composition

Use real component classes and slots. A wrapper can supply layout/context but should
not reimplement the component in ERB. For a page, render actual partials/components;
provide request-specific inputs explicitly and identify limits. Preserve typography,
locale, routes, accessible names, and current token definitions.

## State Grids

A grid makes several meaningful states reviewable on one canvas. Keep it as an example
within the component's existing preview group. Each cell has a clear label and renders
the real component. Use a matrix only when both axes are meaningful; don't make labels
look like editable product controls. Show real usage counts only from verified evidence.

## Interaction

Document the starting state and user action, then test the observable result with the
existing browser stack when appropriate. Focus, Escape, pending state, form errors,
Turbo replacement, and disconnect cleanup need real interaction. CSS snapshots alone
cannot exercise Stimulus or a server form. Use the project's test setup.

## Regression Review

Check unique IDs when several states render together, escaping, labels/described-by,
no missing translations, no external side effects, local font, actual assets, and narrow
width. Avoid global preview mocks that mask missing inputs or override authentication.
Record which states rendered and which runtime conditions remain untested.
