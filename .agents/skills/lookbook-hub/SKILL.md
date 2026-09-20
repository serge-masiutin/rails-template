---
name: lookbook-hub
description: Diagnose the StarterApp Lookbook catalog, run the inventory-to-previews workflow, or select the next focused catalog task. Use for setup, audits, catalog onboarding, and next-step routing.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Hub — Diagnose, Coordinate, Navigate

Use the modes below to inspect the catalog, coordinate a full workflow, select one
focused task, or correct an instruction problem. Specialized skills own inventory,
tokens, flows, previews, comparisons, exploration, Figma delivery, and graduation.
Resolve sibling skills through their installed paths.

## Mode 0: Read-Only Onboarding Check

Inspect manifests/lockfiles, Rails routes, ViewComponent/Lookbook configuration, preview
paths, preview layout/assets, existing previews, and the application's actual rendering
stack. Detect the isolated React viewer separately. Check whether the catalog can boot,
discover, and render a real preview; file presence alone is not readiness.

Report facts, gaps, and the smallest relevant next step. Don't install a new frontend
or generate a full catalog during a request only asking where to start.

## Mode 1: Run the Audit → Previews Workflow

1. Align missing catalog configuration through `lookbook-setup` only if needed.
2. Inventory actual components/call sites and token adoption with `lookbook-inventory`.
3. Assess token health with `lookbook-health` using the same evidence.
4. Map routes, navigation edges, role gates, and shared chrome with `lookbook-flows`.
5. Prioritize heavily used owned components lacking registered previews.
6. Author their materially different states with `lookbook-previews`; use
   `lookbook-comparisons` for a shared state/variant matrix or report surface.
7. Review naming/coverage/decision drift with `lookbook-audit` and record the result.

Run dependent steps sequentially. Don't repeat inventory under each skill or run two
extractors that overwrite the same report. Use one agent by default; this workflow is
not authorization to spawn a team. Keep each step's evidence and unresolved items.

## Mode 2: Navigate to One Next Step

| Observed need | Next skill |
| --- | --- |
| Catalog missing or broken | `lookbook-setup` |
| Unclear real/dead components, usage, coverage | `lookbook-inventory` |
| Raw/undefined/misused tokens or design drift | `lookbook-health` |
| Screens listed but navigation missing | `lookbook-flows` |
| Known component lacks real state examples | `lookbook-previews` |
| Compare variants, aggregate states, display an evidence report | `lookbook-comparisons` |
| Design still being tried | `lookbook-explore` |
| Experiment accepted and ready for production | `lookbook-ship` |
| Approved Figma design/token parity/code mapping | `lookbook-figma` |
| Stale names/decisions/usage | `lookbook-audit` |

Check evidence freshness before routing: source/preview changes since the last report
make its counts suspect. Refresh the affected source once. Registered/rendered previews
are stronger evidence than filenames; a component merely used inside someone else's
preview is not necessarily documented itself. Name unknowns rather than inventing zeros.

## Mode 3: Report a Misfire

When a skill selects the wrong stack or claims an unsupported capability, record the
trigger, actual source evidence, chosen path, and correction. Keep the report free of
secrets/transcripts. Fix a reproducible local instruction problem narrowly; don't add
universal workflow rules based on an unverified guess.

## Resume and Completion

For a long task, keep a compact task summary: scope, completed steps, evidence paths,
unresolved items, next step, and checks. Report only completed/rendered
work as complete; a drafted graph or unrendered preview remains explicitly unverified.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
