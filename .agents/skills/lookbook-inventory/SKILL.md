---
name: lookbook-inventory
description: Inventory real StarterApp ViewComponents, render call sites, variants, token adoption, and registered preview coverage. Use for dead components, component catalogs, and evidence-based preview priorities.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Inventory — Ground Truth from Render Sites

## Collect Once, Verify Surprises

Read the actual component and rendering roots. Use candidate searches such as:

```sh
rg --files app/components app/views test/components/previews
rg -n 'render|\.new\(|renders_one|renders_many' app/components app/views
rg -n 'variant:|size:|status:|Ui::' app/components app/views
```

These are candidate searches, not an accurate parser/count by themselves. Inspect
helpers, presenters, dynamic `render` calls, collection rendering, and controller-selected
templates before declaring a component dead. Source discovery and live framework preview
discovery are separate. Reuse verified evidence in subsequent health/flow reports.

## Report in This Order

1. **Stack:** actual Rails/Hotwire/ViewComponent/Lookbook and separate viewer tooling.
2. **Design system:** declared token source and observed adoption; mixed patterns are
   a transition/finding, not proof that a design document is accurate.
3. **Owned production components:** live, potentially dead, and unresolved, ranked by
   verified render sites. Keep “candidate unused” distinct from proven unused.
4. **Vendor primitives:** report separately from the user's domain components.
5. **Modules/support/scaffold/experiments:** don't pad the production component count.
6. **Tokens and previews:** declared/used/orphan candidates, missing/orphan previews,
   and coverage level (file, discovered, rendered, meaningful states).

## Real Input Usage

For each component record constructor/slot API and actual literal values passed at render
sites. Distinguish omission (default behavior) from an explicit value and a dynamic
expression whose runtime value is unknown. Inspect supported variant maps and relevant
branches; declared-but-unused values are not automatically defects.

Record file:line evidence, parent components, child components, and routed pages reached
through templates/partials. A component reached only through a dynamic render remains
unresolved until verified. Don't call a route dead because it has no `.new` call site.

## Bidirectional Usage

Build or document one consistent map: token ⇄ component ⇄ page. Include primitive-only
token consumption. A page's served route is separate from its reusable-child edges.
Trace helper/partial indirection when it matters. If reports are generated, derive their
counts from the same artifact instead of hand-editing rendered totals independently.

## Present the Result

Use an inventory report/preview when the user needs a shared visual catalog. Keep a compact
usage disclosure with the component's existing preview documentation, not a new sidebar
page for every count. Show real call-site usage beside a state grid when helpful; label
unused supported variants honestly. Foundations show token values/mappings/adoption;
full health findings belong in the health view.

Do not create empty data dashboards before collecting their inputs. Use
`lookbook-comparisons` for inventory/usage/token report recipes. Links target registered
previews; unresolved components remain source labels.

## Full Sweep and Completion

Pass the same evidence to `lookbook-health` and `lookbook-flows`; use the real-component
needs-preview list in `lookbook-previews`. Spot-check zeros, outliers, and suspected
orphans against source before reporting. Record method/freshness and unresolved dynamic
calls.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
