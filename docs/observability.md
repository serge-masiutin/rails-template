# Logs, metrics, and background jobs

[Yabeda](https://github.com/yabeda-rb/yabeda-rails) collects metrics, following the
[Evil Martians stack](https://evilmartians.com/rails-startup-stack).
Rails Semantic Logger emits JSON, Loki stores logs, and Mission Control operates Solid Queue.
Application logs are not stored in PostgreSQL. `AgentTrace` is a separate, sanitized AI execution record
for AgentPrism, with its own seven-day retention.

## Admin

Open `/admin` after normal sign-in. Links are available in navigation and the profile, including Android.
Overview shows a database/worker snapshot, job counts, and queue age.
Shared navigation opens Mission Control, AgentPrism, metrics, and logs.

AnyCable sends invalidation signals after committed queue/trace changes.
The browser fetches authorized HTML/JSON; Turbo morph preserves DOM and AgentPrism preserves selection.
There is no periodic HTTP polling. Bursts are coalesced for 250 ms, with one request at a time
and a ten-second timeout. Hidden tabs stop HTTP requests; visibility return and WebSocket reconnect
fetch a fresh snapshot. Mission Control defers rendering while editing or selecting jobs.
Connection failures show “Connection interrupted”; 401/403 clears displayed data.

`admin:revoke` sends a separate access-check signal. The stream contains no HTML, job arguments,
or trace data. The channel checks the role at subscription; each data request checks it again.
Overview reflects the last event/request. Abrupt worker loss is detected through heartbeat expiry
and Solid Queue process pruning. Prometheus checks availability independently of open admin pages.
This does not verify SMTP or external APIs.

Queue integration uses Notifications and commit callbacks. After a Solid Queue upgrade, run
`OperationsUpdatesTest` and `bin/realtime-test`, including bulk operations and finalization.
Queue broadcasts do not create more queue jobs. Network delivery failures are reported without
undoing committed work; reconnect or the next event retrieves current state.

Sources: [Evil Martians on Turbo morph](https://evilmartians.com/chronicles/the-future-of-full-stack-rails-turbo-morph-drive)
and [Turbo refresh signals](https://turbo.hotwired.dev/handbook/page_refreshes).

| Queue state | Metric key | Meaning |
| --- | --- | --- |
| Ready | `ready` | Waiting to start |
| Scheduled | `scheduled` | Waiting for the scheduled time |
| Claimed | `claimed` | Assigned to a Worker |
| Blocked | `blocked` | Waiting for a concurrency slot |
| Failed | `failed` | Finished with an error |

Process names remain `Worker`, `Dispatcher`, and `Scheduler`. Ready does not mean completed.
Use Mission Control for job details and [AgentPrism](agents.md#agentprism) for AI traces/spans.

Grant/revoke access for an existing account:

```sh
mise exec -- bin/rails admin:grant EMAIL=you@example.com
mise exec -- bin/rails admin:revoke EMAIL=you@example.com
```

[Create the first account](template.md#first-account).
In a configured production environment, use
`bin/kamal app exec --reuse 'bin/rails admin:grant EMAIL=you@example.com'`.
This server operation still needs deployment verification.

New users have `admin: false`; HTTP cannot grant the role.
`Admin::BaseController` and `AdminPolicy` check every request, including AgentPrism JSON and Mission Control mutations.
Guests receive a sign-in redirect for HTML or 401 for JSON; users without the role receive 403.
Password reset revokes sessions. Admin pages disable HTTP/Turbo caching.
The admin role does not bypass product-specific record policies.

### Monitoring links

`/admin/observability` links to Grafana, Prometheus, and log search.
Configure URLs through `config/operations.local.yml` or these environment variables:

| ENV | Purpose |
| --- | --- |
| `OPERATIONS_GRAFANA_URL` | Grafana dashboard |
| `OPERATIONS_PROMETHEUS_URL` | Prometheus queries and alerts |
| `OPERATIONS_LOGS_URL` | Log-store interface |

Production URLs require HTTPS and must not contain credentials/tokens.
Links do not proxy services or pass the app session/Bearer token; each service needs its own access control.
Empty values show “Not configured”. A configured link does not prove service availability.
GitHub Environment variables are passed through the deployment workflow and Kamal.

## Local development

`bin/setup` creates ignored `config/operations.local.yml` with health Basic credentials and a separate metrics token.
For an existing app, run `mise exec -- bin/ops setup`. Restart Rails after changing credentials.

`mise exec -- bin/dev` starts PostgreSQL, Prometheus, Grafana, and Loki in Docker, waits for readiness,
then runs Overmind. Its `logs` process runs Alloy from mise on the host, reading
`log/development.jsonl` directly without Docker Desktop file-sharing caches.
Keep the Alloy version in `mise.toml` aligned with the validation image in `compose.yml`.
Start containers separately with `mise exec -- bin/ops monitoring`; run the collector with `mise exec -- bin/ops logs`.

Loki retains logs for seven days in a Docker volume. Alloy persists read positions in `tmp/observability/alloy`
and follows rotation without importing archives again. Run only one collector per file.
Test logs and the Docker socket are not collected.
Rails uses Ruby Logger for coordinated local rotation: up to five JSONL files of about 20 MiB each,
in a `0700` log directory. Compose container logs use five files of 20 MB each.

| Address | Purpose and access |
| --- | --- |
| `http://localhost:3000/admin` | Overview/navigation; app session with `admin: true` |
| `http://localhost:3000/ops/jobs` | Queues, failures, retries, processes; same admin session |
| `http://localhost:3000/ops/health` | Database and worker heartbeat; separate HTTP Basic |
| `http://localhost:3000/ops/metrics` | Prometheus metrics; separate Bearer token |
| `http://localhost:3001/d/starterapp-logs` | Log search by text/request_id/job_id |
| `http://localhost:3001/d/starterapp` | Grafana dashboard, local Viewer mode |
| `http://localhost:9090` | PromQL, collection targets, and alerts |
| `http://localhost:8091/metrics` | AnyCable metrics, loopback only |
| `http://localhost:9394/metrics` | Job metrics, Bearer authentication; other routes denied |

Development links are set in `config/operations.yml`. Grafana and Prometheus bind only to loopback;
localhost links refer to the host computer, not a separate Android device.
Prometheus scrapes every 15 seconds and retains up to seven days/1 GB.
Grafana dashboards refresh every five seconds; rate graphs need multiple samples.
Loki binds to `127.0.0.1:3100`; Alloy diagnostics bind to `127.0.0.1:12345`.
These ports are not exposed externally. This profile is for development, not production.

Alloy stops with Overmind. Stop monitoring containers with
`docker compose --profile monitoring stop prometheus grafana loki`.
Stop all project containers: `docker compose --profile monitoring --profile realtime --profile images stop`.
When running another app concurrently, change ports and corresponding Prometheus targets.

CI validates Loki, Alloy, Prometheus configuration, and alert rules.
Sources: [Loki](https://grafana.com/docs/loki/latest/configure/examples/configuration-examples/),
[Alloy file collection](https://grafana.com/docs/alloy/latest/reference/components/loki/loki.source.file/).

## Find a log event

Web and workers write one JSON event per line to `log/development.jsonl` and stdout.
Tests use `log/test.jsonl`; production writes only container stdout.
Open Logs from admin and enter text or an ID in Search; expand a row for JSON details.
Grafana Explore supports Live tail. Terminal commands:

```sh
bin/logs
bin/logs --level error
bin/logs --request-id REQUEST_ID
bin/logs --job-id JOB_ID
bin/logs --no-follow --input log/test.jsonl
```

`--level` matches exactly. By default, the command shows the last 200 lines and follows new entries.
`--no-follow` reads the entire file; `--input -` reads stdin. It requires `jq` from Brewfile.

Responses expose `X-Request-Id`; JSON stores it in `named_tags.request_id`.
Enqueue events include `payload.job_id`, linking execution/failure across processes.
`ApplicationJob` and `MailDeliveryJob` preserve the originating request ID; execution logs carry both IDs.
Scheduled jobs may have no HTTP context.

HTTP events include controller/action, status, duration, database time, and render time.
The default level is info; `RAILS_LOG_LEVEL=debug` enables diagnostics.
`Observability::LogFilter` drops only successful INFO metrics/health access events.
Errors, access denials, and ordinary application requests remain. Metric collection is unaffected.
Do not silence an entire controller or raise the global log level just to hide probes.

Only stable `service_name` and `environment` become application Loki labels.
Search request/job/trace IDs in JSON content; do not index them as labels.
[Loki label guidance](https://grafana.com/docs/loki/latest/get-started/labels/bp-labels/).

### Production

With a configured Kamal environment:

```sh
mise exec -- bin/kamal web-logs
mise exec -- bin/kamal job-logs
mise exec -- bin/kamal cable-logs
mise exec -- bin/kamal app logs --since 30m --grep REQUEST_ID
```

Docker keeps five files of 20 MB per container. This bounds size, not retention time.
Removing a container removes its logs. Configure an external stdout collector and protected storage for
longer retention. Local Compose does not configure production ingestion, storage, SSO, or notifications.
Kamal commands have been checked against the CLI; a real production server has not been verified.

## Diagnose a queue failure

1. Open `/ops/jobs`; inspect Failed jobs, Workers, Scheduled, and Blocked.
2. Find `job_id` and correlated logs. Consider the exception, attempts, and completed side effects.
3. Fix the cause. Retry only when safe; do not bulk-retry without investigation.
4. Verify the failed count drops and the queue continues processing.

`mise exec -- bin/ops queue` reads the shared queue database without mutations.
Overmind runs development workers/dispatcher; Kamal uses the separate `job` role in production.
[Concurrency configuration](architecture.md#concurrency) defines threads, processes, and pools;
`queue.yml` defines queues and worker polling intervals.
[recurring.yml](../config/recurring.yml) clears completed production jobs hourly and removes AI traces
older than seven days hourly in development/production. Failed jobs are not automatically deleted.
There is no global automatic retry policy.

`/up` verifies Rails boot for Kamal Proxy. `/ops/health` checks primary/queue connectivity and fresh
worker/dispatcher heartbeats; production also requires a scheduler. Failure returns 503.
Solid Queue heartbeats update once a minute and expire after five minutes.
Health does not prove SMTP delivery, external service availability, or every job's success.

## Metrics and alerts

| Metric | Meaning |
| --- | --- |
| `starterapp_agent_trace_failures` | AI trace storage failures; stage: storage/sdk |
| `imgproxy_requests_total`, `imgproxy_status_codes_total` | Image requests and responses |
| `imgproxy_request_duration_seconds` | Image processing response time |
| `imgproxy_errors_total`, `imgproxy_workers_utilization` | Image errors and worker load |
| `rails_requests_total` | Requests by controller/action/status/format/method |
| `rails_request_duration_seconds` | HTTP duration histogram |
| `rails_db_runtime_seconds`, `rails_view_runtime_seconds` | Database and rendering time |
| `starterapp_queue_jobs{state=...}` | ready, scheduled, claimed, blocked, failed |
| `starterapp_queue_processes{kind=...}` | Processes with fresh heartbeat |
| `starterapp_queue_oldest_ready_age_seconds` | Oldest ready job wait |
| `anycable_go_clients_num` | Active WebSocket connections |
| `anycable_go_publications_total` | Publications received by Go |
| `anycable_go_rpc_error_total` | AnyCable-to-Rails RPC errors |
| `anycable_go_rpc_pending_num` | Pending RPC requests |

HTTP counters belong to one Puma process and reset on restart. The starter uses one Puma process per container.
Before enabling clustered Puma, configure shared Prometheus storage or a separate exporter.
Scrape every web container separately. Queue gauges read the shared database;
do not sum duplicate gauges across web instances. Operational routes and `/up` are excluded from HTTP metrics.

[alerts.yml](../config/observability/alerts.yml) includes initial thresholds for Rails/AnyCable availability,
RPC errors, missing workers/dispatchers, failed jobs, queue age, and HTTP 5xx share.
Alerts appear in Prometheus. Notification delivery is not configured; choose a channel and receiver.
Tune thresholds from actual load; these are starting values, not an SLA.

For production, configure [secrets](deployment.md), scrape `https://<WEB_HOST>/ops/metrics` with
`OPERATIONS_METRICS_TOKEN`, and import dashboards/rules from `config/observability`.
The collector does not need health Basic credentials. Configure separate production storage and access.
AnyCable metrics are internal at `http://starterapp-anycable:8091/metrics`; join the Kamal network
or use a protected tunnel rather than exposing the port.

### AI generation

Find `agent.generated` by request/job ID with `bin/logs`.
`starterapp_agent_generations`, `starterapp_agent_generation_duration_seconds`, and `starterapp_agent_tokens`
show outcomes, duration, and standard input/output usage. They exclude provider pricing and cached-token rates;
they are not a cost calculation. Labels contain bounded agent/action/status or direction, never user IDs.
Missing usage after an error does not mean the request was free.

`bin/jobs` exposes metrics on 9394 with the same Bearer check as `/ops/metrics`.
It binds to loopback in development and the container network in production, without a host port.
Development Prometheus scrapes `starterapp_jobs`. Production collectors should discover `job` container IPs
and scrape 9394 with `OPERATIONS_METRICS_TOKEN`; Docker service discovery follows replacements after deployment.
Fork workers share a file-backed counter store under the supervisor's temporary directory.
Shutdown removes it; a new supervisor starts new counters. Grafana sums web/job counters.
See [AgentPrism](agents.md#agentprism) for sanitized local traces; prompt capture is disabled.

## Write an event

```ruby
Rails.logger.info(message: "Operation completed", payload: { event: "operation.completed", job_id: job_id })
Rails.error.report(error, handled: true, source: "starterapp.integration")
```

Use stable event names and necessary technical fields. Never log request bodies, cookies, Authorization,
job arguments, documents, or user text. The JSON formatter filters parameters, URLs, email recipients/body,
SQL/binds, and known secrets. Exceptions retain class, stack, and causes, while arbitrary messages are removed.
`Rails.error` writes to the same log without external reporting or arbitrary context.
The formatter cannot repair unsafe strings manually interpolated into `message`; keep PII out at the source.

Do not add user/request/job IDs or arbitrary URLs to Yabeda labels.
Test secret exclusion, request-to-job correlation, and failure paths when changing logging.
Android HTTP uses the same server logs. Native crashes/ANRs are available in Android Studio/Logcat;
centralized client error reporting is not connected.

imgproxy metrics bind to localhost:8083 in development and `starterapp-imgproxy:8081` inside Kamal.
Do not expose them publicly. Panels show response codes/p95; `StarterAppImagesUnavailable` fires after
two minutes without metrics. See [images](images.md) for processing and log restrictions.
