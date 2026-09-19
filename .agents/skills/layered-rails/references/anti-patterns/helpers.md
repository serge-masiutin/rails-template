# Complex HTML in helpers

Symptom: A Ruby helper builds an HTML tree, selects domain permissions or hides queries.

Correction: Move stable markup to ERB/ViewComponent and prepare data/access outside. Simple formatting helpers are valid; do not rewrite them merely to expand the component catalog.

Identify the concrete call and consequence. Style or size alone does not prove a defect.
Add a regression test that fails before the correction and passes afterward; do not introduce a parallel layer.

Behavior sources: [app/components/ui/notice_component.rb](../../../../../app/components/ui/notice_component.rb), [docs/architecture.md](../../../../../docs/architecture.md).
