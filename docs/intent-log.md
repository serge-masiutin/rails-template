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
