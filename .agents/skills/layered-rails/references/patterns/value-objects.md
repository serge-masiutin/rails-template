# Immutable values

- Use Data.define or a small explicit class for a stable domain concept with value equality.
- Specify required fields, types, ranges and units at entry; do not repeatedly normalize validated values internally.
- Value objects do not perform network/SQL/write effects in accessors or constructors.
- Data.define freezes the outer object, not nested Hash/Array values. Define ownership and copying explicitly.
- Do not represent money with Float; specify currency/precision. Avoid wrapping every scalar without an invariant.
- StarterappProvider::ToolDefinition demonstrates a small SDK DTO.

Behavior sources: [lib/active_agent/providers/starterapp_provider.rb](../../../../../lib/active_agent/providers/starterapp_provider.rb), [docs/architecture.md](../../../../../docs/architecture.md).
