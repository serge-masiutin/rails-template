---
name: lookbook-explore
description: Prototype a new or redesigned StarterApp component in an isolated Lookbook Explore preview, preserve design evidence, and evaluate the graduation gate before production use.
license: MIT
metadata:
  author: strongeron
---

# Lookbook Explore — Sandboxed Iteration

The design is undecided. Keep experimental code outside `app/components` and production
render paths. Use the existing preview tree/test support with explicit discovery/loading.
Read [exploration.md](references/exploration.md) before scaffolding.

## Before Scaffolding

- Is this a new concept or an iteration on an existing component? This decides the
  graduation path later; it does not justify a second production API now.
- Is there a Figma source? Capture structured design evidence and link the exact node;
  screenshots are visual reference, not authoritative token/prop data.
- What question does the experiment answer? Choose representative content/states and
  a comparison that makes the decision observable.

## Scaffold

Name the preview group `Explore/<topic>/<name>` using installed Lookbook naming/grouping
APIs. Use test-only component/template support; verify production does not load it.
Show a visible draft/pending status and the decision being evaluated. Preserve actual
tokens, typography, and relevant web/Android constraints while allowing the API to evolve.
Use `lookbook-comparisons` only if comparing alternatives or multiple states needs it.

## Graduation Gate

Check four signals: stable API, concrete planned reuse, designer/user review, and tokens
instead of magic numbers. Repeated call sites support a reusable abstraction;
a single-purpose page component can have one consumer.

An accepted one-off remains appropriately local. A reusable component with unresolved
API or design stays in Explore. Record review/decision evidence; don't claim a designer
approved an experiment merely because the agent prefers it.

## Next

Iterate within the authorized task. Once accepted and ready, use `lookbook-ship`, which
preserves the experiment. Keep a compact progress/decision record so another session
can distinguish intended design from an accidentally working prototype.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
