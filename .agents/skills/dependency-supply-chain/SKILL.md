---
name: dependency-supply-chain
description: "Поддерживать зависимости и CI/CD StarterApp: Ruby gems, vendored JS, GitHub Actions и Native SDK."
metadata:
  upstream: secure-npm-package
  adapted-for: StarterApp
  version: "9"
---

# dependency-supply-chain

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- AgentPrism UI/data/types хранятся одним commit в `vendor/agent-prism` с лицензией и SHA-256: npm data отстаёт от UI. Обновляй все три части вместе и проверяй `npm run check:agents`, сборку и browser tests. Node и node_modules нужны только build-stage, в runtime передаются JS/CSS.

- Уважай ограничения совместимости: Node остаётся на актуальной LTS с одной версией в Docker/mise/package.json; panels v3 меняется вместе с AgentPrism upstream. Причины исключений Dependabot — `docs/development.md` и `docs/agents.md`. Не снимай ограничения ради закрытия PR.
- ImageProcessing 2 требует явный `ruby-vips`. Android AGP 9 использует встроенный Kotlin без kotlin-android plugin; обновляй compiler, Gradle wrapper/checksum и lockfile вместе, затем собирай Debug/Release и lint.
- Версии и integrity принадлежат lockfiles, config/agent_skills.json и Gradle wrapper checksum.
- Проверяй источник обновления по официальному репозиторию и release notes. Таблица gems проекта — `docs/architecture.md`: Abstract Notifier входит в Active Delivery, заморозку строк включает Bootsnap вместо Freezolite.
- Active Agent и RubyLLM обновляй согласованно: локальный `StarterappProvider` адаптирует tokens/finish_reason и schema/provider_options tools RubyLLM 2. Удали его, когда контракт поддержит upstream. Проверяй usage, ошибки, schemas и streaming по установленному коду; успешный bundle install не доказывает совместимость. Не возвращай RubyLLM 1.16 с CVE-2026-67991.
- После обновления Ruby проверяй вынесенные stdlib gems: `benchmark` нужен Sniffer/Isolator. Сохраняй тест загрузки и проверки транзакций.
- Используй bin/bundler-audit, bin/importmap audit, npm audit, Brakeman и Dependabot.
- Herb CLI/LSP/formatter — devDependencies в package.json. Устанавливай через `npm ci` с проектным запретом install scripts; запускай локальные bin-команды без скачивания через npx. Обновляй Herb одной группой, согласуй gem и `.herb.yml`, проверь lint и LSP.
- Версию Node.js меняй согласованно в mise.toml и package.json; CI читает package.json. Ruby LSP и Lefthook входят только в development bundle. Не добавляй эти инструменты и node_modules в production-образ.
- GitHub Actions фиксируй commit SHA; разрешения workflow минимальны. PR проверки не получают production secrets.
- Native SDK меняй вместе с потребителями и сборкой Android; проверяй backward compatibility server contracts.
- Деплой выполняется через Kamal workflow с production environment; секреты не попадают в image/build args/logs.
- TestProf/StackProf находятся в test bundle, k6 запускается закреплённым образом из compose.yml. После обновления проверь Minitest plugin, оба режима `bin/test-profile`, k6 smoke и очистку стенда; не добавляй тестовые зависимости в production.
- После обновления запускай релевантные тесты и сборки. Публикацию пакетов/приложений выполняй только по запросу.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/secure-npm-package/SKILL.md`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/secure-npm-package`.
