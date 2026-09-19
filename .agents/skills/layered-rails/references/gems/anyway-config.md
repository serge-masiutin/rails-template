# Anyway Config в StarterApp

- Наследуй конфигурацию от Anyway::Config, объявляй attr_config, coerce_types и on_load с raise_validation_error.
- Пример строгого целого — ConcurrencyConfig::INTEGER: дробное число отклоняется, а не усекается.
- Обязательные группы проверяй вместе, как provider/model/api_key в LlmConfig. Пустая необязательная интеграция разрешена только как явный режим.
- Конфиг подключается при boot; новый ENV/local YAML обновляется вместе с setup, Kamal, CI и docs.
- В Minitest создавай отдельный экземпляр конфигурации с параметрами; глобальное состояние восстанавливай в ensure, если тестируетcя интеграционный wiring.

Источники поведения: [app/configs/concurrency_config.rb](../../../../../app/configs/concurrency_config.rb), [app/configs/llm_config.rb](../../../../../app/configs/llm_config.rb), [test/models/operations_config_test.rb](../../../../../test/models/operations_config_test.rb), [docs/architecture.md](../../../../../docs/architecture.md).
