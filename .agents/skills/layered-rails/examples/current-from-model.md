# Передать пользователя явно

Найди доменный вызов Current.user и всех его потребителей. Actor передаётся из controller после authorize! либо загружается job по ID. Current оставь контекстом HTTP/логов; RequestCorrelatedJob очищает session. Проверь вызов без HTTP и изоляцию конкурентных заданий.

До изменения найди все вызовы. После переноса обнови их атомарно и проверь публичный сценарий. Указанные файлы — действующие примеры; не создавай вымышленные доменные модели ради демонстрации паттерна.

Источники поведения: [app/models/current.rb](../../../../app/models/current.rb), [app/jobs/concerns/request_correlated_job.rb](../../../../app/jobs/concerns/request_correlated_job.rb), [test/lib/concurrency_test.rb](../../../../test/lib/concurrency_test.rb).
