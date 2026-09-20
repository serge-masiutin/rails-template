---
name: hotwire-rails-testing
description: Test StarterApp HTML, Turbo Frames and Streams, forms, flash, deferred requests, authorization, and Native contracts with Minitest and the existing browser stack.
---

# Hotwire Rails Testing

Test the public request/rendering contract:
verify what the user receives, follow redirects before inspecting the destination,
assert no leaked data, and exercise separately requested content separately.

## Choose Coverage by Risk

Start with `docs/testing.md`: name the StarterApp behavior and failure the test must catch.
Extend existing coverage at the simplest sufficient level; a file or configuration change
alone does not require a new test. Rails test scaffolding is disabled intentionally.
Use configuration, linters, or visual review for declarative settings and presentation.
Keep application security and integration regressions; do not reconstruct a dependency's
algorithm or assert its settings as a substitute for exercising our behavior.

## For Changed Behavior, Choose Relevant Assertions

| Behavior | Assertion |
| --- | --- |
| Correct page/component | Response status and meaningful DOM via `assert_select` |
| Rendered data | Rendered values and links within the correct region |
| No leaked data | Forbidden/foreign access and absence of sensitive markup/JSON |
| Flash after a command | 303, destination, `follow_redirect!`, visible notice |
| Validation errors | 422 form HTML, submitted values, error association |
| Deferred content | Initial frame placeholder plus separate authorized frame request |
| Partial reload | Actual `Turbo-Frame` request and matching frame markup |
| Multi-region update | Turbo Stream media type, action, stable target, meaningful template |
| External redirect | Exact trusted destination and rejection of untrusted return URLs |

## Setup

StarterApp uses Minitest and the existing test helpers/fixtures. Read `docs/testing.md` and
the nearest related test before writing another.
Read [minitest.md](references/minitest.md) for concrete request, frame, stream, and
component examples; adapt route/fixture names to the feature under test.

## Redirect and Validation Rules

After a successful POST/PATCH/DELETE, assert the 303 and destination first. Then follow
the redirect before inspecting the rendered flash/page. Invalid forms render 422
directly: do not call `follow_redirect!` on them. Malformed required parameters are 400;
authentication and authorization have their own established response contracts.

## Shared Layout and Access

Exercise guest, ordinary user, allowed owner, foreign record, and administrator where
those are distinct boundaries. Verify that a hidden link's endpoint still denies access.
For private operational pages cover role revocation and no-store behavior. Preserve
existing session/password atomicity and after-commit disconnect regression tests.

## Deferred and Partial Requests

Assert the initial page provides the frame source/loading state without loading deferred
results into its HTML. Request that source with its actual frame header and assert the
matching frame ID, authorized data, and failure states. Each endpoint needs its own
access test; a parent page's authorization does not protect a directly requested frame.

For streams, assert the product's meaningful action/target and content, not every byte
of generated whitespace. Browser tests confirm that actual DOM replacement preserves
focus/input and that repeated navigation doesn't duplicate listeners/subscriptions.

## External Redirects

Test allowed scheme/host and the resulting redirect. Don't follow a redirect to a
real external service in a local test;
assert the location and mock the external boundary where interaction is part of the use case.

## Browser and Native Coverage

Use the existing Cuprite driver for behavior requests cannot prove: keyboard/dialogs,
debounce, Turbo history, form processing, lazy content, and disconnect/reconnect cleanup.
Keep JS failures visible. For Native, distinguish server UA tests, JSON/bridge contract
tests, Gradle checks, and real emulator/device navigation. Report which actually ran.

## Performance and Concurrency

For growing collections, verify N+1 behavior with the project's existing helpers. Use
TestProf before optimizing slow tests. Race tests use real threads, barriers, and bounded
timeouts for the actual invariant; don't infer concurrency correctness from sequential
mocks. Do not run the load-test environment alongside ordinary tests.

## Never Test These Instead of Product Behavior

- Framework internals already covered by the dependency's tests.
- Private instance variables or mocked controller render calls instead of HTTP output.
- A full HTML snapshot for a small semantic contract, or exact JSON for an intentionally
  extensible response. Conversely, use exact keys for a security allowlist/schema contract.
- The same validation case at model, controller, browser, and native layers without a
  distinct risk. Preserve known integration/security regressions even when a library is involved.
- A final notice before following the redirect, or deferred values on the initial response.
- Retry-until-green behavior that hides a flaky lifecycle or infrastructure failure.

## Done

Run the narrow relevant tests first and the required project checks after the change
stabilizes. State commands/results and environment limits; do not imply device, production,
load, or model-quality coverage from ordinary request tests.
