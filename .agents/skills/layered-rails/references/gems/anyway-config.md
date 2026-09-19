# Anyway Config contract

- Inherit Anyway::Config; declare attr_config, coerce_types and on_load validation with raise_validation_error.
- Follow ConcurrencyConfig::INTEGER for strict integers: reject fractional input instead of truncating it.
- Validate required groups together, such as provider/model/api_key in LlmConfig. An empty optional integration is an explicit mode.
- Load configuration at boot. Update new ENV/local YAML with setup, Kamal, CI and docs.
- Instantiate isolated configurations in Minitest. Restore global state in ensure when checking integration wiring.

Behavior sources: [app/configs/concurrency_config.rb](../../../../../app/configs/concurrency_config.rb), [app/configs/llm_config.rb](../../../../../app/configs/llm_config.rb), [test/models/operations_config_test.rb](../../../../../test/models/operations_config_test.rb), [docs/architecture.md](../../../../../docs/architecture.md).
