# Review a change

1. Read the diff and affected call paths, including schemas, Native contracts, docs, skills and CI configuration.
2. Check access, input, errors, atomicity, secrets and preserved behavior. Keep controllers/jobs thin and domain code independent of requests.
3. For Hotwire, check 400/422/303, frame IDs, stream targets, reconnect and Android. For UI, check Martian Mono, long text, accessibility and previews.
4. For integrations, inspect timeout/retry/idempotency, logging and fail-fast configuration. AI requires prompt/model versions, boundary tests and separate quality evals.
5. Run narrow tests, then sufficient broader checks. Validate contracts rather than mere file/dependency presence.
6. Give each defect a scenario, file/line and consequence. Label assumptions; when no defect is found, state scope and limits.

Avoid generic demands to add services, unnecessary warnings or praise in place of evidence.

Behavior sources: [AGENTS.md](../../../../AGENTS.md), [docs/hotwire.md](../../../../docs/hotwire.md), [docs/testing.md](../../../../docs/testing.md).
