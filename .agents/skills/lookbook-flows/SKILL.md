---
name: lookbook-flows
description: Map StarterApp routes, navigation actions, shared chrome, role gates, component usage, and Native destinations. Use for app maps, journeys, navigation audits, and missing flow coverage.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Flows — Connections, Not Just Screens

A route list cannot prove navigation coverage. Map nodes, action-labelled edges,
persistent navigation sources, role boundaries, and unresolved dynamic destinations.
Read [flow-capture.md](references/flow-capture.md) before a whole-app map.

## Collect

Read `config/routes.rb` and, when boot is available, `mise exec -- bin/rails routes`.
Inspect Rails links/forms/redirects, shared layout/header/footer/admin navigation,
component/partial composition, Stimulus navigation, and Native path rules. Routes include
machine endpoints; don't present health/metrics/webhooks as user screens.

Use static search to find candidates, then verify the source. Record every edge with
origin, destination, action, transport/method, access signal, and file:line evidence.
Trace deep helper/service/component navigation back to callers and routed pages.

## Model

- **App map:** complete observed route graph, role lanes, edge kinds, coverage, registered
  preview links, and shared chrome sources.
- **Journey:** one curated persona's ordered path through the observed graph, with named
  states and actions; it is not automatically every possible route traversal.
- **Native:** annotate destination/sheet/external handoff where verified, without creating
  a parallel authorization model.

Use meaningful action labels (“save profile”, “open details”), not just anonymous arrows.
Number journey states when sequence matters and link to actual preview/browser routes.
Use tokens for map chrome and a clear legend for categorical edge/coverage encoding.
Render maps/pages at real width with narrow-screen inspection, not a tiny centered canvas.

## Under-Extraction Loop

Low edge counts or a navigation candidate not represented in the graph are findings.
Inspect the missed idiom, trace its caller/origin, add the supported edge with provenance,
and record genuinely dynamic cases in an unresolved list. If using an extractor, fix
and test the specific source pattern, then regenerate. Never silently drop a route's
edges or invent a plausible destination to make a graph look complete.

## Gate

Sweep every shared navigation source, inspect public/user/admin crossings against actual
guards, spot-check deep edges, and list unresolved cases. Use `lookbook-previews` for the
screen states and `lookbook-comparisons` for map/journey presentation. A static graph is
not proof that a browser/device traversal succeeds; report runtime checks separately.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
