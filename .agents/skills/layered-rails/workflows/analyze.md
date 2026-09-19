# Audit architecture

1. Read manifests, routes, schemas, AGENTS and relevant docs. Select a concrete web/Android journey.
2. Trace HTTP/job → policy → model/operation → database/external API → HTML/JSON, recording each boundary's input, output and effects.
3. Investigate access, integrity, transaction, thread-safety and privacy failures. Verify hypotheses through tests, queries, logs or actual calls.
4. Separate confirmed defects from possible improvements. File size and absence of extra layers are not defects.
5. Fix locally and update consumers, tests, docs and skills together.

Report the scenario, file/line, risk, smallest correction, executed checks and limitations. Avoid a separate long report when the task result and intent log suffice.

Behavior sources: [docs/architecture.md](../../../../docs/architecture.md), [config/ci.rb](../../../../config/ci.rb).
