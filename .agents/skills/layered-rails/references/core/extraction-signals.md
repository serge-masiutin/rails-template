# When to extract an object

- Start with recurring responsibility: access rules, multi-model input, complex queries, external contract conversion, repeated UI or integration.
- File size and method count prompt investigation; they do not prove a defect. Look for repeated invariants, hidden effects or independent reasons to change.
- Use policies for access, queries for read composition, forms for input, ViewComponent for HTML and model-adjacent operations for use cases.
- Preserve signatures/consumers or change them together. Do not add a base class, DSL or dependency for one call.
- Identify the public scenario and test before changing it; report the resulting contract and validation afterward.

Behavior sources: [docs/architecture.md](../../../../../docs/architecture.md), [test/integration/authentication_contract_test.rb](../../../../../test/integration/authentication_contract_test.rb).
