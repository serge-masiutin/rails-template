---
name: lookbook-health
description: 'Audit StarterApp Tailwind/CSS token health: raw colors, missing/unused tokens, scale gaps, design-document drift, and explicitly configured token-family rules.'
license: MIT
metadata:
  author: strongeron
---

# Lookbook Health — Design-System Health Gate

## Inputs and Sequence

Use the current token source and verified usage from `lookbook-inventory`. Inspect
Tailwind v4 `@theme`, CSS custom properties/aliases, ERB/component class lists, custom
utilities, and preview assets.
For a small audit, source evidence is sufficient; a recurring automated report needs a
Rails-aware extractor with a tested contract.

## Checks

| Finding | Inspect | Appropriate action |
| --- | --- | --- |
| Raw color | Hex/rgb/hsl/oklch literals in product styling | Adopt an existing exact semantic token where suitable |
| Undefined token | CSS variables/utilities and their real definitions | Fix the misspelled/missing contract |
| Unused token | Verified consumers including aliases/utilities/primitives | Report candidate; don't delete from one incomplete scan |
| Scale gap | Spacing/type sequence and actual design intent | Explain the gap; don't normalize blindly |
| Design-document drift | DESIGN.md or other claimed values versus actual CSS | Reconcile claims with code and agreed design |
| Property/token family | Designer-authored allowed family for a property | Warning/info unless an explicit CI policy says otherwise |

If a literal resolves to an existing token, don't invent a duplicate token. Resolve alias
chains and modes carefully; distinguish intentionally categorical data colors from UI
chrome. A color match is evidence, but semantic role still matters.

## Optional Property → Token-Family Rules

Apply property-to-token-family rules only when the design contract defines them. Don't infer a
universal rule from token names alone or suddenly make CI red. If requested, define
designer-owned mappings such as text color → content family, background → surface/canvas,
and border → line family. Document intentional component-local aliases and specificity.

## Report

For each finding keep kind, severity, message, source file/line, evidence, and suggested
fix. Summaries must derive from findings. Mark checks skipped because inputs are absent;
do not report zero findings as successful execution. Use the same token adoption data
in inventory and health. A basic Colors view shows value/mapping/adoption; the separate
Health view shows the full diagnostics without repeating banners on every swatch.

## Scope and Deferral

Prioritize broken references and inaccessible/unusable states over cosmetic scale
preferences. During an audit, report broad redesign opportunities separately from the
authorized fix. If design intent is unknown, describe the concrete uncertainty and keep
working on independently verifiable findings. Don't change fonts, invent a dark palette,
or add a linter without an agreed rule to enforce.

## Gate and Next

Run installed relevant lint/build checks after fixes and render affected previews with
actual assets. Use `lookbook-comparisons` for token/health views and `lookbook-audit` for
later drift review. Keep source provenance and state the bounds of the scan.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
