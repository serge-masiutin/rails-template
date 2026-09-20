---
name: lookbook-comparisons
description: Compose Lookbook state grids, A/B decisions, token and usage reports, app maps, and motion experiments using preview-only Ruby/ERB/Stimulus.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Comparisons — Composition Primitives

Use a preview-only wrapper for repeated comparison/report structure. Keep actual product
components inside it; don't reimplement their markup. Read only the needed recipe in
[wrapper-library.md](references/wrapper-library.md). For layered A/B/role/page/motion
composition also read [composition-patterns.md](references/composition-patterns.md).

## Pick by Intent

| Intent | Recipe |
| --- | --- |
| Compare two alternatives | A/B canvas |
| See all material states | State grid or two-axis matrix |
| Review role differences | State grid of verified access-dependent presentation |
| Track a decision | Decision record and dashboard |
| Ordered flow / tagged set | Preview strip/set |
| Tokens and adoption | Tokens canvas / token matrix |
| Inventory, usage, health | Evidence-backed report views |
| Find where an icon/token/component is used | Icon matrix / bidirectional usage explorer |
| Whole application / one persona | App flow graph / journey graph |
| Motion, shader, 3D experiment | Motion stage / WebGL canvas / supported 3D adapter |
| Figma delivery coverage | Design delivery inventory |

## Inputs Before Reports

Data views need verified input first: inventory/usage from `lookbook-inventory`, health
from `lookbook-health`, edges from `lookbook-flows`, design parity from `lookbook-figma`.
Don't scaffold empty dashboards and call them an audit. State grids need the actual
component and its meaningful cases; a decision canvas needs a concrete question.

## Scaffold Locally

Follow the installed preview/template API and keep wrappers in preview/test support.
Use Ruby/ERB for composition and Stimulus only for actual interaction. Original TSX
wrappers remain full reference implementations, but no `ABCanvas` Ruby constant or
`scaffold-wrapper.sh` Rails mode exists until deliberately implemented.

Use one small wrapper when repetition warrants it. Do not generate all tiers or install
React Three Fiber for an ordinary component preview. Nest wrappers when that expresses
the task clearly: decision → A/B layout → real component or motion canvas.

## View Design and Gate

Use tokens/Martian Mono, real widths, accessible controls, and project icons. Keep data
provenance available without repeated banners; experiment status remains visible.
Use registered preview links or honest source labels. Verify unique IDs when rendering
many instances together, actual interaction cleanup, narrow width, and the input data's
freshness. Follow `lookbook-previews` for final discovery/rendering checks.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
