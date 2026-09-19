---
name: hotwire-native-components
description: "Maintain Hotwire Native Android and shared bridge components."
metadata:
  upstream: shadcn-svelte-inertia
  adapted-for: StarterApp
  version: "6"
---

# hotwire-native-components

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `docs/native.md`, Kotlin entrypoints and versioned JSON in `public/configurations`.
- Native text uses `Theme.StarterApp`, `TextAppearance.StarterApp.*` and `res/font/martian_mono.xml`; WebView uses Rails' shared Martian Mono. Preserve the font family and compare local `hotwire_error.xml` when upgrading the SDK.
- Put English native strings in `res/values/strings.xml` and translations in `values-*`. Only published languages belong in `localeFilters` and `locales_config.xml`; see `docs/architecture.md#interface-languages` for WebView synchronization.
- Rails renders shared product screens. Native code supplies navigation, device capabilities and platform UX.
- Assess route changes for Android; configure modality/refresh in `android_v1.json`.
- Use `hotwire-bridge-contracts` for bridge events and register components in the Android application.
- Release uses HTTPS and an explicit production URL; local HTTP is Debug-only.
- Preserve Rails cookies/CSRF and authorize independently of User-Agent.
- Run configuration sync/check, Android lint/build and relevant behavior tests. Report missing SDK/device validation explicitly.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/shadcn-svelte-inertia.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/shadcn-svelte-inertia`.
