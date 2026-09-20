---
name: lookbook-ship
description: Graduate one accepted Lookbook Explore experiment into a production ViewComponent while preserving the experiment, updating consumers and previews, and recording the decision.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Ship — Graduate and Preserve History

The experiment has an accepted design and stable enough contract. Preserve it in place:
copy/apply the accepted implementation into production; never move away the only design
history with `git mv`. Read [graduation.md](references/graduation.md) before changes.

## Decide the Path

- **A — new component:** create the production component from the accepted experiment,
  adapt its namespace/contract, and write fresh production previews.
- **B1 — evolve existing:** apply the accepted changes to the existing production API
  and previews, updating affected consumers atomically.
- **B2 — compatibility window:** retain the old implementation only if real callers
  still require it; name the migration ownership and completion condition.

Do not create a `_legacy` tree simply to avoid understanding callers. A path/name change
requires a source-aware update of Ruby/ERB/controller/preview consumers; unchanged paths
do not require a mechanical rewrite of every caller.

## Execute

Keep production concerns separate from experiment presentation. The production preview
documents real supported states and useful controls, without a permanent “pending decision”
banner. The original experiment remains, annotated chosen/archived with date, selected
variant, production destination, and reason. Related comparison decisions are updated
in place so the catalog no longer shows contradictory pending choices.

## Gate and Next

Run relevant component/request/browser and Ruby/ERB checks; render new production previews.
Refresh actual usage/coverage because a graduated component wasn't previously in the
production graph. Record the decision in the existing project log/profile documentation
without inventing a PR number or committing automatically. Return to `lookbook-hub` only
when another catalog step is needed; do not turn one graduation into a whole-app audit.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
