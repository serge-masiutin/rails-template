# AnyCable updates

AnyCable serves WebSocket connections for web and Android. Rails validates sessions and subscriptions
over HTTP RPC; Go manages connections and history. Redis and a separate Ruby RPC process are not required.
Versions and settings live in `Gemfile.lock`, `config/importmap.rb`, `config/anycable.yml`, and `compose.yml`.

## Run and verify

`bin/setup` generates a shared secret in `config/anycable.local.yml` with mode `0600`.
Git and Docker exclude this file. For an existing installation, run `bin/cable setup`.
`bin/dev` starts AnyCable through Overmind; `Ctrl+C` stops its container.

| Local address | Purpose |
| --- | --- |
| `ws://localhost:8080/cable` | WebSocket; HTML preserves the Android emulator host |
| `http://localhost:3000/_anycable` | Rails RPC with its own Bearer secret |
| `http://localhost:8090/_broadcast` | Rails/worker broadcasts, authenticated with a Bearer secret |
| `http://localhost:8091/metrics` | Go metrics, loopback only |
| `http://localhost:8080/health` | Go liveness; does not verify Rails or delivery |

Never call RPC or broadcast APIs from the browser. Server keys must not appear in HTML or JS.
See [Android](native.md) for LAN access.

```sh
mise exec -- bin/realtime-test
```

This command is part of `bin/ci` and needs Docker, PostgreSQL, and Chrome.
It uses ports 3100, 8180, and 8190, the test database, and a temporary container cleaned up afterward.
It verifies Turbo Stream delivery, missed-message recovery, reload after history loss,
foreign-subscription rejection, session revocation, and admin updates without idle HTTP polling.

## Subscribe and broadcast

After sign-in, the layout subscribes to `Current.user.updates_stream_name` through `UserUpdatesChannel`.
The channel checks both the stream signature and ownership. Define authorization in each new channel;
a signed stream name alone does not grant access to private data.

Publish through `Turbo::StreamsChannel.broadcast_*_to` to the same stream name.
Render HTML with an existing ViewComponent or partial; its target must exist on the page.
Publish after commit. Use ApplicationJob for background product delivery.
`Realtime::HttpBroadcaster` is synchronous and has explicit timeouts: failures propagate,
payloads are not logged, and it does not retry automatically. Each job owns retry and idempotency decisions.

Admin panels use `OperationsUpdatesChannel`. It sends only invalidation signals after commit;
each HTML/JSON request checks the role again. Queue broadcasts do not enqueue jobs, avoiding a feedback loop.
Network failures are reported through `Rails.error` without undoing a committed job.
See the [admin contract](observability.md#admin).

The connection identifies a Rails session; every reconnect validates the cookie again.
Sign-out and password reset use `Session#revoke!` / `Session.revoke_all!`:
sessions are deleted immediately and `DisconnectSessionsJob` closes sockets after commit.
On a network failure, that job retries after five seconds, up to three attempts.
Final failure remains visible in the queue. New revocation operations must not delete sessions directly.

## Recovery and limits

The extended AnyCable protocol uses a memory broker: up to 100 messages per stream, retained for five minutes.
Short disconnects recover missed messages. Lost history emits `history_not_found`, which reloads fresh HTML.
Session caching is disabled so recovery cannot bypass revoked Rails sessions.

This is a single Go-server topology. Restarting clears history; it is not a durable event log.
Choose a shared broker/pubsub before scaling horizontally, update the topology, and rerun recovery tests.
PostgreSQL remains the source of application state.

## Operations

Kamal routes `wss://<WEB_HOST>/cable` to the `anycable` accessory on the same domain.
Go calls `https://<WEB_HOST>/_anycable`; Rails publishes to internal
`http://starterapp-anycable:8090/_broadcast`. Both receive `ANYCABLE_SECRET` from secrets.
Verify TLS and DNS on the deployed server; local tests do not prove production connectivity.

Go logs appear in Overmind's `cable` process locally and `bin/kamal cable-logs` in production.
Go writes JSON at error level: warn can include command payloads and signed stream names.
Rails reports RPC errors through `Rails.error`; metrics show availability and error rates.
Do not enable verbose logging on user traffic without filtering.
See [observability](observability.md) for dashboards, alerts, and collection.

After transport changes, run `bin/realtime-test`, check connection/RPC metrics, navigation,
sign-out, and Android recovery from the background.
Sources: AnyCable [Hotwire](https://docs.anycable.io/guides/hotwire),
[HTTP RPC](https://docs.anycable.io/ruby/http_rpc), and [Kamal](https://docs.anycable.io/deployment/kamal).
