# Image processing

imgproxy resizes and converts images. Rails stores originals through Active Storage and signs URLs;
web and Android use the same HTML. Versions are pinned in `Gemfile.lock` and `compose.yml`.

## Run and verify

`bin/setup` creates local keys and Active Storage tables. `bin/dev` starts imgproxy with Overmind.
For an existing checkout:

```sh
mise exec -- bin/images setup
mise exec -- bin/rails db:prepare
mise exec -- bin/dev
```

Keys live in ignored `config/imgproxy.local.yml`, mode `0600`.
Health: `http://localhost:8082/images/health`. Metrics: `http://localhost:8083/metrics`.
Both bind to loopback by default. Physical devices need the [Android LAN configuration](native.md).

```sh
mise exec -- bin/rails test test/lib/image_variant_url_test.rb
mise exec -- bin/image-test
```

The first checks URL generation/contracts. The second runs a temporary container on 8382/8383,
uploads a synthetic 128×64 PNG through Active Storage, receives a 32×16 WebP, checks signature,
expiry, and external-source rejection, then removes the blob and container.
Metrics are saved in `tmp/images/imgproxy.prom` and uploaded by CI. Both checks are part of `bin/ci`.
The PNG fixture is in `test/fixtures/files`.

## Use in a screen

For a model with `has_one_attached :photo`, use the standard variant API:

```erb
<%= image_tag record.photo.variant(resize_to_limit: [800, 600], format: :webp),
      alt: "Image description", loading: "lazy" %>
```

The actual field and alt text belong to the feature. Authorize the record before exposing its URL.
Add upload forms and domain fields with a real feature: validate user, blob ownership, size, and detected MIME;
do not trust the filename or client Content-Type. Direct uploads need their own authentication and limits.

Do not call `.processed` or enable `preprocessed: true`; those trigger local Rails variants.
Define transformations in code; never pass raw params to variant or `imgproxy_options`.
`Images::VariantUrl` uses the imgproxy-rails converter, preserves `format`, rejects unknown Rails transforms,
and leaves the input hash unchanged. Explicit `imgproxy_options` take precedence except for mandatory expiry.

`image_processing`, explicit `ruby-vips`, and system libvips remain for Active Storage metadata analysis.
ImageProcessing 2 no longer installs adapters transitively; removing `ruby-vips` breaks Rails boot.
imgproxy still performs image transformations. PDF/video previews are not configured;
they need a separate feature and imgproxy Pro when using that service.

## Storage and access

The container reads development `storage/` or production `starterapp_storage` read-only.
Sources are restricted to `local:///`; HTTP, metadata endpoints, and arbitrary external URLs are rejected.
S3 or multiple application servers require shared object storage and changes to `Images::VariantUrl`.

HMAC-signed URLs expire after 15 minutes; result caching is limited to one minute.
They are bearer URLs: anyone holding one can read until expiry, even after sign-out.
Use separately authorized delivery for documents requiring immediate revocation.
Do not cache HTML beyond its image URLs' lifetime.

Initial limits: 20 MiB / 25 megapixel source, 4096-pixel result side, one animation frame,
two workers, and a 16-request queue. Measure time and memory before changing them.

Kamal routes `/images` to imgproxy on the same HTTPS domain.
Development redirects to port 8082 on the request hostname, including Android hosts.
See [deployment](deployment.md) for keys and accessory upgrades.

## Diagnostics

[Prometheus/Grafana](observability.md) includes imgproxy panels and an availability alert.
Check response-code rates, p95, `imgproxy_errors_total`, and worker utilization.
Local logs: `overmind connect images`. Production: `bin/kamal image-logs`.
The service writes error-level JSON. Its logs may contain short-lived signed URLs;
restrict access and remove URLs/IPs before sharing externally.

Sources: [imgproxy-rails](https://github.com/imgproxy/imgproxy-rails),
[imgproxy options](https://docs.imgproxy.net/configuration/options),
[Evil Martians stack](https://evilmartians.com/rails-startup-stack#image-processing).
