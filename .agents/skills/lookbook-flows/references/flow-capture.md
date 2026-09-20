# Flow Capture for Rails and Native

## Route Nodes

Capture method/path/controller/action, human label, screen versus machine endpoint,
parameters, actual access policy, optional preview URL, and Native presentation.
Route-name/path heuristics can suggest a role but must not override controller/policy
evidence. A missing preview is a coverage gap, not a missing route.

## Edges and Navigation Sources

Inspect `link_to`, `button_to`, `form_with`, redirects, Turbo frame targets, programmatic
visits, and existing operational JS. Shared header/sidebar/footer links contribute edges
from every applicable screen, not only the template where the link is defined. Keep
action/method, success/failure destination, query state, and source file/line.

Distinguish read navigation, form mutation/redirect, local disclosure, frame replacement,
external link, authentication boundary, and native presentation. Not every local toggle
deserves a route node; record it as a state transition when it matters to the journey.

## Deep-Edge Tracing

A helper or component can render a link for several pages. Follow callers through partials,
component composition, helpers/presenters, and controller-selected templates. Record
the shared source and its attributed pages. Don't assign an edge to a service as if the
service were a screen. Dynamic polymorphic URLs require concrete call-site evidence;
unknown targets remain unresolved with the expression and reason.

## Roles

Review guest/user/admin paths through real authentication, `authorize!`, scopes, and
navigation visibility. A hidden link does not close an endpoint. Trace login return paths
and logout/session revocation. Native UA changes chrome only. Mark expected denied
crossings and test representative unauthorized requests; don't infer security from a map.

## Graph Validation

Every destination resolves to a known route, an intentional external URL, or an unresolved
case. Every edge has provenance. Spot-check a direct edge, shared-chrome edge, deep edge,
mutation redirect, and role crossing. Compare source changes against the previous map:
shrinking edges may indicate parser drift rather than simplified navigation.

## Journey Authoring

Choose a persona and outcome, then list states, triggers, and observable results. Include
meaningful invalid/empty/permission states, not just a happy-path screenshot strip.
Use stable labels and actual preview links. A journey is curated from captured facts;
don't auto-generate every combination or conflate desired future flow with shipped flow.

## Native Verification

Match path rules to actual URLs and installed destination classes. Test direct link,
sheet presentation/dismissal, Back, form success/error, session expiry, and external links
when the native behavior changes. Preserve versioned config compatibility and sync
bundled copies. Mark device-unverified annotations separately from observed navigation.
