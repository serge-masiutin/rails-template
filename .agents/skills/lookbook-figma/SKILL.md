---
name: lookbook-figma
description: Bring approved Figma designs and foundation tokens into StarterApp ViewComponent/Lookbook, verify design-code parity, and prepare authorized code-to-design mappings. Use for delivery and token sync, not undecided exploration.
license: MIT
metadata:
  author: strongeron
---

# Figma ↔ Lookbook — Tokens, Delivery, and Code Mapping

Approved design → this skill. Undecided options → `lookbook-explore`; accepted local
experiment → `lookbook-ship`; documenting existing code → `lookbook-previews`.
Read [figma-workflow.md](references/figma-workflow.md) for capture and parity details.

## Job 0: Capture Structured Evidence

Resolve the actual file/node, token CSS, and scope. Use available Figma structured tools
for variables, design context, and node structure. Tool names/shapes depend on the
installed connector: discover them instead of assuming a source package's API is active.
Use screenshots for visual comparison, not exact token/prop extraction.

Capture necessary design responses with file/node/tool/freshness provenance in a safe
task-local store; persist only appropriate project design artifacts. Don't store credentials,
private unrelated designs, or raw transcripts. If a response truncates, descend into
the relevant child nodes and capture those. Reuse fresh captures rather than repeating
the same calls, but don't present stale cached data as a live fetch.

## Job 1: Foundation Tokens

Normalize variables, units, typography/effects, aliases, and modes. Compare them with
actual Tailwind/CSS tokens, resolving `var()` chains and color representation. Report
matched, drifted, missing, and intentionally app-only roles. A screenshot color sample
is not a token definition. Preserve Martian Mono unless the user explicitly changes the
project's typography contract.

Use one parity dataset for the token view and health report. Show Figma name/value,
code token/value, adoption, and drift with a justified tolerance for color conversion;
spacing/type comparisons retain their units. Missing token semantics require a concrete
design decision, not silent invention of a magic value.

## Job 2: Approved Component Delivery

Audit existing components before adding another. Build the accepted design using actual
ViewComponent/Stimulus patterns and tokens; follow `lookbook-previews` for material states,
factories, and controls. Record the exact design node/link near the preview. Use supported
Lookbook documentation/linking instead of claiming `parameters.design` works in Rails.

Split a large board into coherent sections, completing implementation and validation
for each while preserving the overall task. Keep a delivery inventory keyed by stable
node/component/preview identifiers; repeated delivery updates existing entries and
unions the delivered previews. Don't lose earlier sections by overwriting the inventory.

Compare actual rendering at relevant widths and available themes. Verify real text,
tokens, hierarchy, component states, keyboard behavior, and native constraints. A claimed
Figma match needs an actual visual comparison, not only a successful build.

## Job 3: Code → Design

Gather existing node links, real component inputs/slots/variants, token parity, and usage.
Prepare a concrete mapping payload/snippet with correct Ruby/ERB usage, names, and design
property aliases. Verify that the available Figma/Code Connect mechanism supports the
target representation; don't relabel a React-specific generated binding as ViewComponent.

Publishing mappings or creating design artifacts follows the user's explicit authorization.
Prepare the reviewable mapping before any final permission step if one is needed. A request
to inspect or implement a design does not itself request generating new Figma documents.

## Gate and Next

Report captured versus unavailable/stale inputs, token drift, delivered components/previews,
actual rendering checks, and prepared versus published mappings. Do not fabricate a tool
response when no connector/export is available. Continue source-based implementation where
independent; identify the exact missing design input for blocked parity claims.

## StarterApp Workbench Contract

Use Rails/ViewComponent/Lookbook for product UI and inspect the actual component,
call sites, tokens, preview configuration, and tests first. Read the shared
[workbench contract](../lookbook-hub/references/workbench.md) for paths, evidence,
data ownership, lifecycle, layout, and verification.
