# Plan a local change

1. Define required behavior and web/Android constraints. Read affected implementations, contracts and checks.
2. Identify the owning layer; reuse configuration, policies, deliveries, jobs, components and test tools.
3. Choose the smallest change, affected consumers and validation order. Justify a dependency, cache or orchestration with a measurable need.
4. Cover malformed input, foreign data, rollback, concurrency and external-service failure where relevant.
5. Update docs and working skills in the same change. Proceed after adequate investigation without a separate approval process for reversible local edits.

Provide a short executable plan with completion criteria. Do not create a plan file unless maintenance needs it.

Behavior sources: [AGENTS.md](../../../../AGENTS.md), [docs/architecture.md](../../../../docs/architecture.md), [docs/testing.md](../../../../docs/testing.md).
