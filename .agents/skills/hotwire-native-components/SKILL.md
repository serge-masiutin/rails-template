---
name: hotwire-native-components
description: "Развивать мобильную часть StarterApp на Hotwire Native Android и совместные bridge-компоненты."
metadata:
  upstream: shadcn-svelte-inertia
  adapted-for: StarterApp
  version: "5"
---

# hotwire-native-components

Контекст: StarterApp, Ruby 4.0 / Rails 8.1, PostgreSQL, Turbo/Stimulus/importmap,
Tailwind 4, ViewComponent/Lookbook, Hotwire Native Android, Overmind, Kamal.
Сначала прочитай корневой AGENTS.md. Отвечай и пиши новые комментарии по-русски.

## Рабочий контракт

- Прочитай `docs/native.md`, Kotlin entrypoints, versioned JSON в `public/configurations`.
- Нативный текст использует `Theme.StarterApp`, `TextAppearance.StarterApp.*` и `res/font/martian_mono.xml`; WebView — общий Martian Mono из Rails. Не подменяй семейство в новых элементах. При обновлении SDK сверяй локальный `hotwire_error.xml`.
- Нативные строки храни в `res/values/strings.xml` на английском, переводы — в `values-*`. В `localeFilters` и `locales_config.xml` включай только опубликованные языки; общий список и синхронизация языка WebView описаны в `docs/architecture.md#языки-интерфейса`.
- Общий продуктовый экран рендерит Rails; нативный слой обеспечивает навигацию, системные возможности и platform UX.
- Изменение маршрута оцени сразу для Android. Правила модальности/refresh задаются в android_v1.json.
- Для bridge-событий используй `hotwire-bridge-contracts`; регистрируй компонент в Android-приложении.
- Release использует HTTPS и явный production URL. Local HTTP доступен только Debug.
- Аутентификация использует Rails cookies и CSRF. Не доверяй User-Agent при проверке прав.
- После изменения выполняй sync/check конфигураций, Android lint/build и релевантные тесты поведения. Не выдавай отсутствие SDK за успешную проверку.

## Результат

Сообщи конкретные изменения или выводы, выполненные проверки и непроверенные части.
Источник адаптации: `https://evilmartians.com/agent-skills/shadcn-svelte-inertia.tar.gz`; происхождение и полный upstream сохранены в
`config/agent_skills.json` и `vendor/agent-skills/evilmartians/shadcn-svelte-inertia`.
