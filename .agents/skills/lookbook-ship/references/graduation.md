# Graduation and Decision Preservation

## Inputs

Identify the exact experiment, accepted version, decision evidence, public inputs/slots,
planned callers, and checks. An ambiguous “ship this” needs the visible/current experiment
resolved from context, not a guessed component. Preserve the user's existing authorization.

## New Component

Copy only the implementation that belongs in production. Rename namespace/paths to the
existing conventions, remove preview-only sample data, and make required inputs explicit.
Write fresh production previews using `lookbook-previews`; don't copy the whole experiment
including draft status and comparison controls. Wire real callers and verify no production
code imports test support.

## Existing Component

Apply the chosen delta to the actual component and preserve its established contract
unless the accepted design requires a change. Update every affected caller, test, preview,
and instruction together. If a live compatibility window is needed, keep the old path
explicitly deprecated and record remaining callers. No empty compatibility shell or silent
fallback should conceal a broken migration.

## Close the Decision Loop

Keep the experiment at its original location with chosen/archived state, decision date,
winner, destination, and rationale. Update linked A/B comparisons and pending decision
lists. Rejected alternatives remain distinguishable from accepted but deprecated code.
Never erase design history merely to make the sidebar look clean.

## Archive Levels

An experiment can retain executable source, a smaller documented snapshot, or a durable
decision record depending on future review value. Reducing preserved material is a
separate intentional task, not an automatic side effect of graduation. Don't delete live
callers or the only record of a decision. Large archives may warrant review, not blind
pruning at a numeric threshold.

## Verification

Check production imports/render sites, stable IDs/inputs, variants, translations, assets,
keyboard/lifecycle behavior where changed, and preview discovery/rendering. Refresh the
verified inventory/usage graph and state exactly what ran. Deployment/publication is not
implied by a local component graduation request.
