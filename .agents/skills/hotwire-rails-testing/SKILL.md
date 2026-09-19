---
name: hotwire-rails-testing
description: "Тестировать StarterApp: Rails Minitest, ViewComponent, браузер с Cuprite и контракты Native."
metadata:
  upstream: inertia-rails-testing
  adapted-for: StarterApp
  version: "14"
---

# hotwire-rails-testing

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Для админки проверяй гостя, обычного пользователя, администратора, отзыв роли, JSON 401/403, CSRF Mission Control и no-store. Сессия не заменяет Basic/Bearer технических endpoints; обратное тоже запрещено. Общую навигацию и Native HTML проверяет `test/system/admin_test.rb`.

- Для AgentPrism проверяй настоящий цикл Active Agent → SDK local_store → очищенный JSON, usage без двойного счёта, ошибку записи, retention и доступ по роли администратора. UI проверяет `test/system/agent_prism_test.rb`; сначала `npm run build:agents`. Новые SDK-поля не должны автоматически попадать в БД/RAW.

- Для Active Storage/imgproxy запускай `bin/image-test`: реальное преобразование, размеры/формат, подпись, срок ссылки и запрет внешних источников. Обычные тесты генерации URL не доказывают обработку в Go.

- Для AI проверяй HTTP-запрос/ответ, usage, ошибки без повторов, commit/rollback, request/job ID и отсутствие текстов в логах; пример — `test/agents/application_agent_test.rb`. Тесты транспорта не заменяют quality evals: каждой функции нужен версионируемый набор обычных, ошибочных и adversarial случаев.
- Для UI проверяй английские тексты, `lang`, ошибки форм и письма; i18n должен отклонять неизвестные locale, обнаруживать отсутствующий перевод и восстанавливать язык после запроса. Пример — `test/integration/localization_test.rb`.
- Используй Minitest и fixtures по существующему test/. Внешний HTTP закрыт WebMock, localhost разрешён для system tests.
- Сначала запускай конкретный файл, затем релевантный набор и `bin/ci`. Команды, диагностика и артефакты — `docs/testing.md`.
- Для медленных тестов сначала измерь SQL через `bin/test-profile sql` или CPU через `bin/test-profile cpu`, затем сравни тот же набор после изменения. Профили выполняются в одном процессе; обычный Linux CI сохраняет параллелизм.
- Нестабильный тест воспроизводи с seed из падения. Исправляй утечку состояния, часы или ожидание события; не добавляй автоматические retries и sleep в system tests. Cuprite должен поднимать ошибки JavaScript.
- Isolator включён в development/test и должен поднимать ошибки. Не отключай его ради зелёного теста; проверь commit и rollback, если меняешь побочный эффект.
- Для коллекций используй `assert_perform_constant_number_of_queries` с разным размером данных; пример — `test/models/queue_snapshot_test.rb`. Сам gem без такого теста N+1 не ищет.
- Проверяй доставку через Active Job и запрет доступа к чужой записи. При проверке настоящего commit используй `self.use_transactional_tests = false` и убирай созданные данные.
- Гонки проверяй реальными потоками с барьером и таймаутом, разными DB-соединениями и получением ошибок через `Thread#value`; пример — `test/lib/concurrency_test.rb`. Sleep не обеспечивает нужного порядка. Для проверки cleanup проверь Current, лог-теги и возврат соединения после ошибки.
- Integration tests проверяют статусы, redirect, cookies, доступ, HTML и Turbo Stream targets.
- В system tests зарегистрируй используемые пулы БД до открытия fixtures; подключение пула в потоке Puma нарушает учёт транзакций Isolator при teardown. Сохраняй раннюю регистрацию SolidQueue::Record в application_system_test_case.rb; не подавляй предупреждение отключением Isolator.
- ViewComponent tests проверяют смысловой DOM и варианты. System tests запускают реальный Chrome через Cuprite.
- Параметры Cuprite передавай через `driven_by ... options:`: Rails перезаписывает ручную регистрацию `:cuprite`. Проверяй фактические параметры через `BrowserDriverTest`; `process_timeout` относится к запуску Chrome, а не к ожиданию DOM.
- Для Turbo проверь успешную отправку, validation 422, history, reconnect Stimulus. Не синхронизируй тесты sleep-вызовами.
- Для изменений WebSocket запускай `bin/realtime-test`: реальный Go-сервер и Chrome проверяют доставку, recovery, потерю истории, чужую подписку и отзыв сессии. Обычные Rails tests перехватывают broadcasts и не доказывают доставку.
- HTTP/WebSocket-нагрузку проверяй через `bin/load-test smoke|load`. Стенд использует локальную test-БД, временного пользователя, CSRF, приватную подписку и настоящую доставку; не запускай его параллельно другим тестам. Ошибки и отсутствие доставки должны нарушать thresholds. Проверяй cleanup и отчёты k6/Yabeda; локальный результат не доказывает production capacity.
- Native tests проверяют schema/path rules и синхронность bundled/remote JSON. Изменения Kotlin требуют платформенной сборки.
- Отдельно сообщай результаты Ruby, браузерных и Android проверок. Сборка APK не заменяет проверку навигации на устройстве.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/inertia-rails-testing.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/inertia-rails-testing`.
