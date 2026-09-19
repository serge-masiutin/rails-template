# Configuration boundaries

- Use Anyway Config in app/configs and native integration configuration. Read shared settings through Rails.configuration.x; do not scatter ENV reads across requests.
- Declare types, required fields, ranges and parameter groups. Partial LLM settings or an undersized database pool must fail boot.
- Developer overrides live in ignored config/*.local.yml; production secrets come from Kamal env.secret. Keep them out of images, docs and Git.
- Configure at process startup. Never mutate shared SDKs, ENV or singleton settings per request.
- Keep one source of defaults, such as ConcurrencyConfig. Test boundaries, malformed input, each environment and SECRET_KEY_BASE_DUMMY builds.
- Verify precedence from the installed Anyway Config version and actual loader; do not guess credential/local/ENV ordering.

Behavior sources: [app/configs/concurrency_config.rb](../../../../../app/configs/concurrency_config.rb), [app/configs/llm_config.rb](../../../../../app/configs/llm_config.rb), [test/models/concurrency_config_test.rb](../../../../../test/models/concurrency_config_test.rb), [test/models/llm_test.rb](../../../../../test/models/llm_test.rb).
