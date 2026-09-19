# Third-party materials

The root MIT license applies to template code. Third-party sources, instructions, fonts and
dependencies retain their authorship and licenses. The template does not imply endorsement by their authors.

| Material | Source and notices |
| --- | --- |
| Evil Martians skills and adaptations | [Catalog](https://evilmartians.com/agent-skills); originals in `vendor/agent-skills/evilmartians`; sources and SHA-256 in `config/agent_skills.json`; [adaptation map](docs/agent-skills.md) |
| Evil Martians Agent Skills | [Repository](https://github.com/evilmartians/agent-skills), MIT; license in `vendor/licenses/evilmartians-agent-skills.txt` |
| Layered Rails | [Vladimir Dementyev / palkan](https://github.com/palkan/skills), MIT |
| Storybook Workbench: sb-* sources | Author `strongeron`; MIT stated in upstream SKILL.md frontmatter; working adaptations use ViewComponent/Lookbook |
| AgentPrism | [Evil Martians](https://github.com/evilmartians/agent-prism); [MIT license](vendor/agent-prism/LICENSE); commit and SHA-256 in `vendor/agent-prism/source.json` |
| Martian Mono | [Evil Martians](https://github.com/evilmartians/mono); [SIL OFL 1.1](vendor/fonts/martian-mono/OFL.txt); version and SHA-256 in `vendor/fonts/martian-mono/manifest.json` |
| Importmap JavaScript | Versions and URLs in `config/importmap.rb`; sources and license headers in `vendor/javascript` |
| Gradle wrapper | [Gradle](https://github.com/gradle/gradle), Apache-2.0; headers retained in `gradlew` / `gradlew.bat` |

Library versions are pinned in Gemfile.lock, package-lock.json and the Android lockfile.
Preserve copyright notices, licenses, provenance and checksum verification when updating dependencies.
