# GitHub CI/CD and deployment

## CI

[ci.yml](../.github/workflows/ci.yml) checks pull requests and pushes to `main`:
Rails/PostgreSQL, real AnyCable delivery/recovery, imgproxy processing/security,
production assets, Docker, Prometheus/Loki/Alloy configuration, alerts, Android Debug/Lint, and Release/R8.
Debug APKs are artifacts. Unsigned Release uses `https://build.invalid` only for build validation.
These jobs receive no production secrets.

Require `rails`, `android`, and `container` in a GitHub ruleset; the workflow itself does not protect branches.
Actions are pinned by SHA. [Dependabot](../.github/dependabot.yml) updates Actions, gems, npm, Gradle, and Docker.
Node runs Herb and builds AgentPrism in a separate Docker stage; runtime excludes Node/node_modules.
CI checks types, vendored provenance, and the viewer. See [developer tools](development.md) for local checks/hooks.
The manual **Test diagnostics** workflow runs TestProf or a k6 scenario; see [testing](testing.md).

## GitHub setup

1. Set an SSH remote such as `git@github.com:<owner>/<repository>.git` and push `main`.
   Configure identity/SSH through `git config --local`; the template does not select an account.
   HTTPS remotes do not use SSH settings.
2. Create a `production` Environment, allow `main`, and configure reviewers if required.
3. Set the variables/secrets below. Grant the repository Actions access to an existing GHCR package.

### Variables

| Name | Value |
| --- | --- |
| `DEPLOY_HOST` | Server IP or hostname |
| `DEPLOY_USER` | SSH user with Docker privileges |
| `DEPLOY_ARCH` | `amd64` or `arm64` |
| `WEB_HOST` | Domain without scheme or port |
| `KAMAL_IMAGE` | Lowercase `owner/starterapp` |
| `SMTP_ADDRESS` | SMTP host |
| `MAIL_FROM` | Sender address |
| `OPERATIONS_GRAFANA_URL`, `OPERATIONS_PROMETHEUS_URL`, `OPERATIONS_LOGS_URL` | Optional HTTPS admin links without credentials/tokens |

### Secrets

| Name | Value |
| --- | --- |
| `SSH_PRIVATE_KEY` | Dedicated deployment SSH key |
| `SSH_KNOWN_HOSTS` | Server key verified outside the workflow |
| `SECRET_KEY_BASE` | Output of `bin/rails secret` |
| `ANYCABLE_SECRET` | Separate `bin/rails secret` output, shared by Rails/Go, at least 64 characters |
| `IMGPROXY_KEY`, `IMGPROXY_SALT` | Two separate `openssl rand -hex 32` outputs, shared by Rails/imgproxy |
| `DB_PASSWORD` | Persistent PostgreSQL password |
| `SMTP_USERNAME`, `SMTP_PASSWORD` | SMTP credentials |
| `OPERATIONS_USERNAME`, `OPERATIONS_PASSWORD` | Health HTTP Basic; password at least 32 characters |
| `OPERATIONS_METRICS_TOKEN` | Separate metrics token, at least 32 characters |

GHCR uses `GITHUB_TOKEN` with `packages:write`. `.kamal/secrets` references ENV.
`kamal config` can contain secrets; do not publish its output.

To enable Gemini, set the `LLM_API_KEY` secret (or the same ENV for local deployment).
Provider and model defaults live in `LlmConfig`. The app boots without the key; generation requires it.
Web and jobs share this Active Agent/RubyLLM configuration. See [AI setup](agents.md)
and [worker metrics](observability.md#ai-generation).

## Deploy

[config/deploy.yml](../config/deploy.yml) places web, workers, AnyCable, imgproxy, and PostgreSQL on one server.
Kamal Proxy terminates TLS and routes `/cable` to AnyCable, `/images` to imgproxy, and other paths to Rails.
Database, broadcast, and metrics ports remain internal. PostgreSQL and Active Storage use persistent volumes.
The web container runs `db:prepare` on startup.

Before the first deployment, configure DNS, open 80/443, and verify SSH.
Before accepting users, verify SMTP, set database/file backups, and test restoration.
Automatic backups are not configured in this starter.

Run **Deploy production** with `setup` for the first deployment or `deploy` for updates.
Deployment follows CI and Environment checks; concurrent deployments are serialized.
For local deployment, export settings and run `mise exec -- bin/kamal setup` or `mise exec -- bin/kamal deploy`.
These commands still require validation on a real server. Kamal builds committed Git state.
Application rollback does not revert migrations; keep schemas compatible with the previous version.

Normal `deploy` does not update accessories. After changing imgproxy's image, settings, or keys,
run `mise exec -- bin/kamal accessory reboot imgproxy`. Rails/service keys must match;
rotation invalidates old URLs. imgproxy reads the originals volume read-only; back it up with Active Storage.

After changing AnyCable's image/settings, run `mise exec -- bin/kamal accessory reboot anycable`
from the configured environment. This drops connections and memory history; verify [recovery](realtime.md).

See [observability](observability.md) for log collection, health, metrics, and production monitoring requirements.
After first deployment, [grant the admin role](observability.md#admin) and open `/admin`.
Migrations never grant existing accounts access automatically.
