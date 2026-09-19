# Логи, метрики и traces

- Используй существующие Rails.logger, Rails.error, ActiveSupport::Notifications и Yabeda. Subscriber отделяет форматирование и измерение от доменной операции.
- Событие имеет устойчивое имя, статус, длительность и технические идентификаторы. Request/job ID принадлежат логам, а labels метрик — ограниченным наборам значений.
- Сохраняй exception cause/stack; не интерполируй exception.message, пользовательский текст, URL с токеном, params, документы и ключи в message.
- StarterApp JsonFormatter скрывает известные чувствительные поля, но не очищает произвольно собранные строки. Проверяй отрицательный сценарий с маркерами секретов.
- Web и jobs имеют разные endpoints метрик; счётчики fork-воркеров объединяет WorkerMetrics. Очередь измеряется по общей БД, поэтому её gauges нельзя суммировать с нескольких web-инстансов.
- Новая метрика меняется вместе с dashboard, alert и promtool-сценарием. Начальные thresholds не объявляй production SLO без измерений.
- AI traces проходят allowlist AgentTrace::Document и retention. Потеря диагностики наблюдаема и не должна повторять оплаченный вызов модели.

Источники поведения: [docs/observability.md](../../../../../docs/observability.md), [lib/observability/json_formatter.rb](../../../../../lib/observability/json_formatter.rb), [lib/observability/agent_subscriber.rb](../../../../../lib/observability/agent_subscriber.rb), [test/lib/observability/json_formatter_test.rb](../../../../../test/lib/observability/json_formatter_test.rb).
