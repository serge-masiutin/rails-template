# Developer tools

`mise exec -- bin/setup --skip-server` installs gems, npm packages, and this repository's Lefthook pre-commit hook.
Ruby and Node versions are pinned in `mise.toml`; `package.json` also pins Node for npm and GitHub Actions.
Docker, mise, and npm must agree on Node 24 LTS. Upgrade to the next LTS together;
Dependabot keeps the Docker image within the selected major.
[Node release schedule](https://nodejs.org/en/about/previous-releases).

Node runs Herb and builds the isolated AgentPrism viewer. Product pages use importmap.
See [AgentPrism commands](agents.md#agentprism).

## Development tools

The admin sidebar links to Lookbook (`/lookbook`), Mail previews (`/rails/mailers`),
Rails routes (`/rails/info/routes`) and local Alloy diagnostics (`http://localhost:12345`).
These links appear only in development. Lookbook is the ViewComponent catalog; Storybook is not installed.
The main navigation also links to Mission Control, AgentPrism and Monitoring, which contains Grafana, Prometheus and Logs.
Health and metrics endpoints are machine interfaces with separate credentials, not browser tools.

The standalone worker retains its loaded classes until restart. After changing Ruby code used by jobs,
run `overmind restart jobs`. Web requests retain normal development reloading.

## Editor

`.vscode/extensions.json` recommends Ruby LSP, Herb, Tailwind CSS IntelliSense, and EditorConfig
for VS Code and Cursor. Install workspace recommendations through Extensions;
repository settings do not install extensions automatically.

- Ruby LSP uses mise Ruby, bundled RuboCop, and the Rails add-on for models, routes, and tests.
  The add-on needs a reachable development database. Ruby formats on save.
- Herb understands HTML/ERB and Action View. Editor and CLI share `.herb.yml`.
  Run ERB formatting and fixes explicitly; saving does not rewrite templates.
- `.editorconfig` defines encoding, line endings, and indentation.

Other LSP editors can run these commands from the workspace root over stdio:

```sh
mise exec -- bin/ruby-lsp
mise exec -- bin/herb-language-server
```

Ruby LSP uses `Gemfile.lock`; Herb CLI/LSP uses `package-lock.json`.
The VS Code Herb extension bundles its own server. The pinned CLI verifies results before commit.

## Checks and fixes

| Task | Command from the project root |
| --- | --- |
| Ruby and Ruby examples in README/docs | `mise exec -- bin/rubocop` |
| Safe Ruby corrections | `mise exec -- bin/rubocop -a path.rb` |
| HTML/ERB, including Turbo Streams | `mise exec -- bin/erb-check` |
| One template | `mise exec -- bin/erb-check app/views/accounts/show.html.erb` |
| Format a template | `mise exec -- bin/erb-format app/views/accounts/show.html.erb` |
| Check formatting without writing | `mise exec -- bin/erb-format --check app/views/accounts/show.html.erb` |
| Full project check | `mise exec -- bin/ci` |

See [testing](testing.md) for test selection, TestProf, k6, and flaky-test diagnosis.
Herb Formatter is experimental: review its diff and run the affected screen test.
Formatting does not block CI; linter errors and warnings do.

Mark Ruby examples as `ruby` and shell examples as `sh`. RuboCop checks syntax and style,
not execution. Archives, dependencies, and skills containing teaching counterexamples are excluded;
`bin/skills check` validates skill structure.

RuboCop includes Rails Omakase, `rubocop-thread_safety`, and `rubocop-md`.
[RuboCop Gradual](https://github.com/skryukov/rubocop-gradual) is useful for an existing backlog.
This starter checks all code without a baseline, so Gradual is not installed.

## Git hook and CI

Lefthook selects RuboCop, Herb, skills, and Native checks by changed files.
Linters inspect entire working files, do not fix them, and do not stage changes.
For partial commits, remember that unstaged content is also checked. These hooks do not need a database.

After editing `lefthook.yml`, run `mise exec -- bin/lefthook install`.
Run hooks manually with `mise exec -- bin/lefthook run pre-commit`.
Hooks invoke pinned tools through mise; the Git client must have `mise` in PATH.
Global Git/SSH and other repositories' hooks are unchanged.

GitHub CI uses `npm ci` and `bin/ci`, including `npm audit`.
`.npmrc` disables install scripts. Dependabot updates Herb as a group;
keep npm packages, gem `herb`, and `.herb.yml` compatible.

Sources: [Evil Martians stack](https://evilmartians.com/rails-startup-stack),
[Ruby LSP](https://shopify.github.io/ruby-lsp/), [Herb](https://herb-tools.dev/configuration),
[Lefthook](https://lefthook.dev/configuration/lefthook/).
