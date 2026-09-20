---
name: lookbook-audit
description: Review StarterApp Lookbook naming, preview coverage, controls, usage drift, archived experiments, and pending decisions. Use for periodic catalog audits and stale decision review.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Audit — Drift and Decision Review

## Sequence

Start with the inexpensive naming/coverage survey. Inspect current preview classes,
group names, real APIs/callers, and existing decision records. A heavy archive review
is useful when the catalog contains enough past experiments to reveal drift.

When checking coverage, refresh verified component/variant usage and preview registration.
Use `lookbook-inventory` once, then reuse its evidence for controls, health, and flows.
Don't regenerate the same artifacts independently or trust stale counts after source edits.

## Decide from Findings

| Finding | Action |
| --- | --- |
| Many names for the same state | Propose a consistent term with actual examples |
| One harmless naming outlier | Avoid a broad rename without value |
| Stale pending decision | Record owner/question/evidence; don't invent acceptance |
| Chosen experiment lacks destination | Trace production use and repair decision metadata |
| Preview controls don't affect output | Fix valid inputs or omit controls deliberately |
| Declared-unused variant is now shipped | Update state evidence/labels and coverage |
| Component loses all parents/pages | Investigate actual deletion versus extraction drift |
| Navigation edge disappears | Use the under-extraction loop in `lookbook-flows` |
| Missing/undefined token | Route to `lookbook-health` |

## Lifecycle and Archive

Distinguish draft, pending, chosen, rejected, archived, deprecated, and production. Keep
chosen experiments where they were created; use `lookbook-ship` for graduation and its
preservation rules. Archive reduction requires an intentional scope and a durable record;
an audit does not automatically authorize deletion or a commit.

## Common Anti-Patterns

Watch for mega-previews with unrelated components, duplicated mock data, unsupported
variants, arbitrary state Cartesian products, static lookalikes labelled real pages,
fake CSS interaction states, production imports from Explore, duplicate usage dashboards,
invented links, stale generated reports, and broad preview mocks hiding missing inputs.
Inspect the affected reference and implementation when a finding appears.

## Ledger and Completion

Record actionable findings with date, evidence, scope, and next action in the existing
project documentation/task record. Keep unrelated production issues marked as outside
the documentation pass unless fixes were requested. Do not send stakeholders messages
or commit the ledger without authorization. Report what was checked, what changed, and
unresolved decisions; route only the next necessary task through the hub.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
