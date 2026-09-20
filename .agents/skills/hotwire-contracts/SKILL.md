---
name: hotwire-contracts
description: Define and verify typed boundaries for Stimulus DOM values, Rails JSON, Hotwire Native JS/Kotlin messages, and the existing TypeScript viewer. Use for shared/page-specific data and contract drift.
---

# Hotwire Boundary Contracts

Give shared and feature-specific data explicit shapes. Consumers must agree with
producers, and missing required fields must fail visibly. StarterApp product pages are
HTML; type DOM values and actual JSON boundaries.

## Choose the Boundary

| Consumer | Contract | Source of truth |
| --- | --- | --- |
| ERB/ViewComponent | Explicit Ruby inputs/variants/slots | Component initializer and templates |
| Stimulus | Targets, typed values, event detail | Controller declarations and rendered attributes |
| JSON endpoint | Allowlisted fields, types, optionality, version | Serializer/schema and request tests |
| Native bridge | Event, payload, response, capability/version | JS + Kotlin implementations and tests |
| Native path configuration | Versioned JSON and bundled copies | `public/configurations/*_v1.json` |
| AgentPrism viewer | Existing TypeScript contracts | Viewer types and `AgentTraceDocument` |

Read actual consumers before changing the schema. Use the existing language and type
conventions at each boundary.

## Shared Versus Page-Specific Data

Keep global contracts small. A page-specific field belongs in that page/component's
input, not a global bag that forces every caller to fake a value. Shared display data
doesn't imply sharing a whole model. Auth, locale, flash, and validation each have their
existing Rails owner; don't mirror them as an unvalidated client store.

Required fields must be accessed directly after validation. Optional fields need an
explicit meaning: absent, null, empty, and unknown are not interchangeable. For IDs,
timestamps, money, and enums, specify representation, units, timezone, and allowed values.

## DOM Contracts

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]
  static values = { endpoint: String }

  connect() {
    if (!this.hasEndpointValue || this.endpointValue.length === 0) {
      throw new Error("An endpoint value is required")
    }
    this.outputTarget.setAttribute("aria-live", "polite")
  }
}
```

Stimulus defaults for missing values do not validate required configuration. Validate
once at connection/configuration entry, then use the established fields directly.
The example requires both endpoint and output target; don't silently skip missing markup.
Resolve URLs against the allowed origin/route contract before network use.

## BAD Versus GOOD

| Avoid | Prefer |
| --- | --- |
| `payload.id || 0` for a required ID | Validate presence/type, then use `payload.id` |
| A type assertion that claims fetched JSON is valid | Parse unknown input at the boundary |
| Optional chaining through required nested fields | Required schema fields and a visible contract error |
| A global index signature hiding unknown keys | Named shared fields plus a local feature type |
| Client-supplied role/owner as authority | Server authorization using the authenticated actor |
| JS/Kotlin changes in separate incompatible releases | Version/capability plan and compatible consumers |

## JSON and Native Bridge

Describe event name, request fields, response fields, errors, lifetime, and concurrency.
Validate payload once on each external boundary. Keep secrets and arbitrary form text
out of bridge messages when an action ID is sufficient. Associate replies with the active
request/screen; discard legitimately stale replies by the documented lifecycle contract.

Capability absence can be a normal supported state for older clients: render working
HTML and don't send unsupported messages. Malformed data for an advertised capability
is an error, not an excuse to fabricate defaults. Define timeout/error UX for an operation
that may not reply; don't invent hidden retries or duplicate commands.

StarterApp has the bridge framework installed, but a new feature component still needs
real JS/Kotlin implementation and registration. Inspect existing files instead of
claiming `Bridge.send` or a particular component is already available.

## TypeScript Where It Exists

The AgentPrism viewer is a separate React/TypeScript consumer. Keep its existing module
types and build conventions. For a JSON boundary, use `unknown` until parsed; avoid
`as SomePayload` to conceal drift. A `type` versus `interface` choice follows the actual
library constraint.

Errors such as missing properties, incompatible nullability, and widened string enums
should lead back to the producer/consumer contract. Don't suppress them with `any`,
non-null assertions, or a global augmentation for fields only one screen provides.
Vue/Svelte reactive access is not part of StarterApp product pages; Stimulus value-change
callbacks and fresh DOM reads address stale local configuration when relevant.

## Generation and Serialization

Alba/Typelizer are not installed. Don't promise automatic Ruby-to-TypeScript/Kotlin
generation. Reuse an existing schema/generator if present; introduce one only for an
actual repeated contract need, with generator inputs, command, output ownership, and
CI drift checks. Handwritten types still require boundary validation and parity tests.
See `rails-serialization` for allowlists and data-loading boundaries.

## Compatibility and Verification

Version incompatible Native contracts while retaining the old endpoint for installed
clients. Run `bin/native sync` after the authoritative config change and `bin/native
check` to detect drift. Test required/optional/null fields, invalid enums, malformed JSON,
unknown events, unauthorized requests, disconnect, duplicate/late replies, and an older
supported client. Compile affected Kotlin/TypeScript consumers using existing commands.

Do not call a JavaScript/Kotlin bridge verified from a Rails request test alone. Document
the checks actually run and any device/runtime gap.
