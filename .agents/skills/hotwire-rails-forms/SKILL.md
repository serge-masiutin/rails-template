---
name: hotwire-rails-forms
description: "Build web and Hotwire Native forms with explicit validation and upload contracts."
metadata:
  upstream: inertia-rails-forms
  adapted-for: StarterApp
  version: "6"
---

# hotwire-rails-forms

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Read `docs/images.md` for uploads. Use imgproxy through `.variant(...)`, never `.processed` or `preprocessed: true`. Check user/blob ownership, size and MIME server-side; a signed URL is not authorization.
- Use `form_with`, labels, server validation messages and ordinary submit buttons.
- GET renders the form; successful mutations return 303; invalid submissions return form HTML with 422.
- Preserve the outer frame ID on validation failures. Use `data-turbo-frame="_top"` when leaving a frame.
- Stimulus handles local interaction; the server validates required values independently.
- For multiple models, use an explicit form object and one transaction where atomicity is required.
- Change modal rules in `public/configurations/android_v1.json`, then run `bin/native sync` and `bin/native check`.
- Test disabled submission, repeated submission, errors, keyboard, back navigation and modal dismissal in web and Android.
- Use `render :new, status: :unprocessable_entity` on invalid models and a 303 `redirect_to` on success.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/inertia-rails-forms.tar.gz).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/inertia-rails-forms`.
