---
name: rails-content-visibility
description: "Expose genuinely public Rails content to search engines and agents without leaking private data."
metadata:
  upstream: llms-visibility
  adapted-for: StarterApp
  version: "4"
---

# rails-content-visibility

Read root `AGENTS.md` first. Use the actual manifests, code and tests as sources of truth.
Write repository content in English and respond in the user's preferred language.
Context: Rails, PostgreSQL, Turbo/Stimulus/importmap, Tailwind, ViewComponent/Lookbook,
Hotwire Native Android, Overmind and Kamal.

## Working contract

- Establish which pages are public by inspecting authentication and permissions.
- Public HTML needs a correct title, headings, readable content and canonical URL.
- Add Markdown/JSON representations only for a concrete consumer with the same access rules.
- robots.txt and llms.txt are not authorization. Exclude the workspace, sessions, password reset and user records from indexing.
- Set correct Content-Type and Vary for content negotiation and test caching behavior.
- Test guest/user access, absent secrets and consistent HTML/Markdown content.
- Deliver an accessible public resource and boundary tests; do not promise ranking improvements.

## Completion

Report concrete changes or findings, executed checks and unverified behavior.
Adapted from [Evil Martians](https://evilmartians.com/agent-skills/llms-visibility/SKILL.md).
Provenance and original SHA-256: `config/agent_skills.json`; full upstream:
`vendor/agent-skills/evilmartians/llms-visibility`.
