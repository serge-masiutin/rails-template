# Журнал решений

Записывай здесь значимые решения проекта: результат, проверки, ограничения и следующий шаг.

## 2026-09-19 — воспроизводимость шаблона

- Добавлена первоначальная настройка: [контракт](template.md), `bin/configure` и пять тестов CLI.
  Переименовываются исходники, Android package, конфигурация, метрики, документация и skills;
  история Git, локальные данные и сторонние исходники не переносятся из других проектов.
- На чистой копии с именем AcmePortal и ID `com.acme.portal` прошли `bin/setup` и `bin/ci`:
  117 Rails-тестов / 509 проверок, 8 браузерных / 39, AnyCable / 12, imgproxy / 10 и k6 / 44.
  Также прошли production assets, Docker-сборка, Android Debug/unsigned Release/lint,
  Actionlint, Prometheus config и 10 alert rules. Локальные ссылки и сохранность vendor проверены.
- GitHub runners, production deploy, внешний SMTP/LLM и Android на устройстве этим запуском не проверялись.
  Перед выпуском нового приложения выполни проверки и настрой эксплуатацию по [деплою](deployment.md).
- Опубликован [GitHub Template](https://github.com/serge-masiutin/rails-template):
  публичный репозиторий с отдельной историей и основной веткой `main`; первый Actions CI запущен.

## 2026-09-19 — обновления Dependabot

- Обновлены Puma 8.0.2, ImageProcessing 2.1.0 с явным ruby-vips, Lucide 1.46.0 и setup-node 7.
  Puma сохраняет IPv4 listener. Android переведён на AGP 9.4.1, встроенный Kotlin 2.4.20
  и Gradle 9.7.1; wrapper и dependency lock пересозданы и проверены.
- Node остаётся на 24 LTS, panels — на v3 до совместимого обновления AgentPrism.
  Причины и условия перехода — в [разработке](development.md) и [AI](agents.md).
  Dependabot продолжает проверять эти зависимости; Android build-зависимости сгруппированы.
- Локально прошли полный `bin/ci`: 117 Rails-тестов / 509 проверок,
  8 браузерных / 39, AnyCable / 12, imgproxy / 10 и k6 / 44. Проверены skills и сохранность vendor.
  Собраны Android Debug и unsigned Release. Lint: 0 ошибок, 3 предупреждения о SDK
  и сжатии ресурсов; запуск на устройстве не выполнялся.
- Следующий шаг после публикации — проверить CI основной ветки GitHub и закрытие заменённых PR.

## 2026-09-19 — запуск Chrome в CI

- Устранена потеря настроек Cuprite: Rails повторно регистрировал драйвер и оставлял
  стандартные 10 секунд на запуск Chrome. Настройки перенесены в `driven_by`:
  запуск — 30 секунд, команды — 10, ошибки JavaScript включены.
- Новый `BrowserDriverTest` проверяет параметры реального браузера после регистрации Rails.
  Правило добавлено в [инструкцию тестирования](testing.md), testing skill и сценарии его проверки.
- Полный локальный `bin/ci` прошёл: 117 Rails-тестов / 509 проверок, 9 браузерных / 43,
  AnyCable / 12, imgproxy / 10, k6 / 44. Результат GitHub CI хранится в Actions соответствующего коммита.
