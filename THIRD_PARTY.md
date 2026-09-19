# Сторонние материалы

MIT в корне применяется к коду шаблона. Сторонние исходники, инструкции, шрифты и зависимости
сохраняют авторство и свои лицензии; название шаблона не означает одобрения их авторами.

| Материал | Источник и сведения |
| --- | --- |
| Skills и адаптации Evil Martians | [Каталог](https://evilmartians.com/agent-skills), оригиналы в `vendor/agent-skills/evilmartians`, источники и SHA-256 в `config/agent_skills.json`; соответствие адаптаций — [docs/agent-skills.md](docs/agent-skills.md) |
| Evil Martians Agent Skills | [Репозиторий](https://github.com/evilmartians/agent-skills), MIT; текст лицензии — `vendor/licenses/evilmartians-agent-skills.txt` |
| Layered Rails | [Vladimir Dementyev / palkan](https://github.com/palkan/skills), MIT |
| Storybook Workbench — исходники sb-* | Автор `strongeron`, MIT указан в frontmatter оригинальных SKILL.md; рабочие адаптации используют ViewComponent/Lookbook |
| AgentPrism | [Evil Martians](https://github.com/evilmartians/agent-prism); MIT — [vendor/agent-prism/LICENSE](vendor/agent-prism/LICENSE); commit и SHA-256 в `vendor/agent-prism/source.json` |
| Martian Mono | [Evil Martians](https://github.com/evilmartians/mono); SIL OFL 1.1 — [лицензия](vendor/fonts/martian-mono/OFL.txt), версия и SHA-256 в `vendor/fonts/martian-mono/manifest.json` |
| JavaScript для importmap | Версии и URL — `config/importmap.rb`; исходники и лицензионные заголовки — `vendor/javascript` |
| Gradle wrapper | [Gradle](https://github.com/gradle/gradle), Apache-2.0; заголовки сохранены в `gradlew` / `gradlew.bat` |

Версии библиотек закреплены в Gemfile.lock, package-lock.json и Android lockfile.
При обновлении сохраняй уведомления об авторстве, лицензии, происхождение и проверку контрольных сумм.
