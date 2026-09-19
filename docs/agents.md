# AI-функции: Active Agent и RubyLLM

`ApplicationAgent` задаёт общие настройки генераций. Конкретный агент хранит промпт,
принимает проверенный контекст и возвращает ответ; доменная операция проверяет результат
и явно сохраняет его. Генерация сама по себе не создаёт продуктовую функцию или чат.

## Подключить провайдера

Задай вместе `LLM_PROVIDER`, `LLM_MODEL`, `LLM_API_KEY` через ENV или игнорируемый
`config/llm.local.yml` с полями `provider`, `model`, `api_key`. Поддержаны `openai`, `anthropic`,
`gemini`. Перезапусти web и jobs: ключ SDK устанавливается только при загрузке процесса.
В Kamal используются те же параметры; ключ передаётся как secret.

Без настроек приложение запускается, но генерация завершается ошибкой до HTTP-запроса.
Модель проверяется по локальному реестру RubyLLM. `LLM_REQUEST_TIMEOUT` — таймаут HTTP,
по умолчанию 30 секунд, допустимо 1–300. Повторы SDK и заданий автоматически не включаются.

Версии закреплены в Gemfile.lock. `StarterappProvider` расширяет стандартный адаптер Active Agent:
читает `tokens` и `finish_reason` RubyLLM 2 вместо удалённых методов 1.x,
передаёт tools через `parameters_schema` и `provider_options`. Сетевые вызовы и цикл вызова tools
остаются в gem. При обновлении проверь этот контракт и убери локальную адаптацию,
когда upstream будет совместим. RubyLLM 1.16 не подходит из-за CVE-2026-67991.

## Добавить агент

- Создай именованный класс в `app/agents`, наследник `ApplicationAgent`, и константу
  `PROMPT_VERSION` со строковой версией. Меняй её вместе с существенным изменением промпта.
- Действие собирает контекст и вызывает `prompt`. Текстовые ERB-шаблоны храни в
  `app/views/<имя_агента>/`: `instructions.text.erb` и `<действие>.text.erb`.
  `instructions: true` требует шаблон и поднимает ошибку при его отсутствии.
- Считай пользовательский текст данными. Отделяй его от инструкций и проверяй результат
  до записи в БД, вызова tools или рендера. Не передавай ответ модели в `html_safe`.
- Доменная операция явно вызывает `<Агент>.<действие>(...).generate_now` вне транзакции.
  В controller долгий вызов не выполняй: поставь прикладное задание с ID записи,
  заново проверь доступ в worker, вызови агент и сохрани проверенный результат.
- `generate_later` использует `AgentGenerationJob`, очередь `agents`, постановку после commit
  и перенос `request_id`. Результат возвращается внутри worker; callback сохранения
  или доставка в UI автоматически не появляются. Для сохранения предпочтительнее явная прикладная job.
- Аргументы Active Job хранятся в БД очереди. Передавай ID, а не секреты и полные документы.
  Не рассчитывай на Current.user в worker: пользователь передаётся явно и проверяется заново.

Для короткого вызова без шаблонов доступен `Llm.build_chat`; сетевой запрос выполняет `chat.ask(...)`.
Не меняй общую конфигурацию RubyLLM внутри запроса. Ключи и модель не принимаются из params.

Structured output, tools и потоковая выдача требуют отдельных контрактов и тестов конкретной функции.
Формат schema RubyLLM отличается от `response_format` Active Agent: текущая база проверяет
текстовую генерацию и простой tool loop; передачу JSON Schema через адаптер нельзя считать готовой без проверки.
Для schema-вызова используй `Llm.build_chat.with_schema(...)` и валидируй ответ.
Для tools задай явный `max_tool_turns`, права, допустимые аргументы, лимиты и идемпотентность.

## Веб и Android

Оба клиента получают сохранённый результат через общий ERB/ViewComponent и Turbo Stream.
Используй существующую приватную подписку AnyCable и стабильный DOM target.
Ключ провайдера остаётся на сервере. Промежуточный текст модели также рендери с экранированием;
состояния ожидания, отказа и ошибки должны работать и после перезагрузки страницы.

## AgentPrism

Открой «Трассы AI» в `/admin` или перейди на `/ops/agents`.
Доступ — через обычную сессию пользователя с `admin: true`; выдача и отзыв прав описаны
в [наблюдаемости](observability.md#админка). HTML гостя переходит на вход, JSON возвращает 401;
пользователь без роли получает 403. HTTP Basic и токен метрик просмотрщик не открывают.

После вызова `ApplicationAgent` нажми «Обновить»: панель показывает дерево генерации,
LLM и tools, длительность, статусы, версию промпта, request/job ID и сообщённый usage.
Трассы выводятся страницами по 20. Прямой `Llm.build_chat` SDK Active Agent не инструментирует.
До первого вызова список пустой; демонстрационные агенты и платные запросы автоматически не запускаются.

- `AgentTrace::Document` переводит SDK spans в контракт AgentPrism и сохраняет только разрешённые поля.
  Промпты, ответы, аргументы/результаты tools, произвольные events и сообщения исключений удаляются.
  В RAW находится этот же очищенный контракт; для ошибки доступен класс, для traceback — коррелированный лог.
- Локальный `local_store` работает синхронно по завершении генерации; API-ключ и внешний endpoint
  телеметрии отключены. Сбой записи не повторяет вызов модели: он виден в Rails.error,
  `starterapp_agent_trace_failures`, Grafana и alert `StarterAppAgentTraceFailures`.
- Таблица `agent_traces` находится в основной PostgreSQL. Срок — 7 дней; scheduler удаляет
  старые записи раз в час в development/production. Панель сразу скрывает просроченное.
  Ручная очистка: `mise exec -- bin/rails runner 'AgentTrace.prune'`.
- Трасса содержит не более 256 spans и 32 уровней; нарушение контракта отклоняется с метрикой ошибки.
  Неизвестный usage не отображается как ноль. Cached input учитывается отдельно,
  reasoning повторно не суммируется с output. Стоимость не вычисляется.
  Usage отражает ответ SDK; его нельзя считать полным счётом всех HTTP-вызовов tool loop.
  Завершённый span без статуса SDK помечен warning, а не успешным.

Просмотрщик — отдельная React-сборка `app/frontend/agents` и layout Operations без importmap.
Общие экраны приложения продолжают использовать Hotwire; переход в просмотрщик требует полной загрузки.
AgentPrism UI/data/types скопированы из одного commit в `vendor/agent-prism` с MIT-лицензией
и SHA-256 в `source.json`: npm-релиз data отстаёт от текущих компонентов.
При обновлении меняй эти три части вместе, сохраняй manifest и проверяй сборку/браузерные тесты.
Стили адаптированы к Tailwind 4 отдельным конфигом без изменения исходников компонентов.
`react-resizable-panels` остаётся на v3: текущий upstream импортирует `PanelGroup` и `PanelResizeHandle`,
которых нет в v4. Dependabot продолжает обновлять v3; запрет major снимается вместе с совместимым
обновлением AgentPrism и проверкой desktop/mobile UI. Lucide обновляется независимо.

```sh
mise exec -- npm run check:agents
mise exec -- npm run build:agents
mise exec -- bin/rails test test/agents/application_agent_test.rb test/models/agent_trace test/controllers/operations
mise exec -- bin/rails test test/system/agent_prism_test.rb
```

`bin/setup` собирает просмотрщик, `bin/dev` запускает watcher, `bin/ci` проверяет типы,
происхождение и сборку. Docker собирает JS/CSS отдельным Node-stage; в runtime Node и node_modules нет.
Источник UI: [AgentPrism Evil Martians](https://evilmartians.com/opensource/agent-prism).

## Диагностика и проверки

Событие `agent.generated` содержит agent/action, версию промпта, provider/model, статус,
время и usage, если его вернул провайдер. Request/job ID находятся в обычных лог-тегах.
В логи не записываются тексты, API-ключи и сообщения исключений; traceback сохраняется.
Трассы SDK сохраняются локально для AgentPrism; захват тел запросов и `/rails/agents` отключены.
Метрики и endpoint worker описаны в [наблюдаемости](observability.md).

`mise exec -- bin/rails test test/agents/application_agent_test.rb` проверяет ERB, изоляцию диалогов,
HTTP-контракт, простой tool loop, usage, ошибки без повторов, приватность логов, commit/rollback и контекст задания.
WebMock закрывает внешний HTTP. Реальные провайдер и модель пока не выбраны, платные вызовы не выполнялись.
Тесты транспорта не оценивают качество ответов: новая AI-функция требует версионируемого набора
типичных, ошибочных и adversarial примеров с явными критериями и регрессией при смене промпта/модели.

Источники: [разбор Active Agent у Evil Martians](https://evilmartians.com/chronicles/exploring-active-agent-or-can-we-build-ai-features-the-rails-way),
[адаптер RubyLLM](https://docs.activeagents.ai/providers/ruby_llm),
[инструментирование](https://docs.activeagents.ai/framework/instrumentation).
