# Конфигурация на границе

- Источники: Anyway Config в app/configs и штатные конфиги интеграций. Общие параметры читаются через Rails.configuration.x; ENV не размазываются по запросам.
- Объявляй типы, обязательность, диапазоны и согласованные группы параметров. Частично заданный LLM-провайдер или недостаточный DB pool должны останавливать загрузку.
- Переопределения разработчика находятся в игнорируемых config/*.local.yml; секреты production поступают из Kamal env.secret. Не добавляй их в image, docs и Git.
- Изменяй конфигурацию при запуске процесса. Не меняй общий SDK, ENV или singleton config во время обработки запроса.
- Источник дефолта один: например, ConcurrencyConfig. Проверяй крайние значения, malformed input, test/development/production и build с SECRET_KEY_BASE_DUMMY.
- Сверяй precedence по установленной версии Anyway Config и фактическому загрузчику; не придумывай приоритет credentials/local/ENV.

Источники поведения: [app/configs/concurrency_config.rb](../../../../../app/configs/concurrency_config.rb), [app/configs/llm_config.rb](../../../../../app/configs/llm_config.rb), [test/models/concurrency_config_test.rb](../../../../../test/models/concurrency_config_test.rb), [test/models/llm_test.rb](../../../../../test/models/llm_test.rb).
