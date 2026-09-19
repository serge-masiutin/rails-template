# Design a regression test

1. State one user contract and observable failure. Choose the nearest level from docs/testing.md.
2. Test HTTP access/input/response, domain invariants/rollback, UI actions or shared Native contracts plus a platform build as appropriate.
3. Use current Minitest 6 and fixtures. Stub network boundaries with WebMock; use real SQL/concurrency when correctness depends on them.
4. Reproduce the failure before fixing it. Do not add sleeps, hidden retries, skipped checks or fixtures that duplicate implementation.
5. Run related scenarios afterward. Define AI malformed/adversarial cases and quality evals from the product task.

Report the command, observed failure before the correction, success afterward and unverified behavior.

Behavior sources: [docs/testing.md](../../../../docs/testing.md), [test/integration/password_reset_atomicity_test.rb](../../../../test/integration/password_reset_atomicity_test.rb), [test/system/authentication_test.rb](../../../../test/system/authentication_test.rb).
