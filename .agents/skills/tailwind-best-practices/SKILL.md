---
name: tailwind-best-practices
description: "Maintain Tailwind styles, shared design tokens and accessible ViewComponent markup."
metadata:
  upstream: tailwind-best-practices
  adapted-for: StarterApp
  version: "5"
---

# tailwind-best-practices

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Gemfile.lock owns versions; tailwindcss-rails builds `app/assets/tailwind/application.css`.
- All font families use `--font-ui` from `app/assets/stylesheets/typography.css`: local Martian Mono only. New layouts include `shared/typography`; test Cyrillic and long text on narrow screens.
- Define semantic colors in `@theme` and reuse the spacing/typography scale.
- Extract repeated UI into ViewComponent with fixed variants.
- Keep class lists readable: layout, spacing, typography, color, interaction; use px/py for paired directions.
- Use complete class literals, including Ruby variant maps; avoid interpolated class names.
- Do not extract components through `@apply`; markup and contracts belong in ViewComponent.
- Check focus-visible, contrast, mobile safe areas, long text and production `assets:precompile`.
- Use `VARIANTS.fetch(variant)` to select fixed classes instead of accepting arbitrary className values.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/tailwind-best-practices/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/tailwind-best-practices`.
