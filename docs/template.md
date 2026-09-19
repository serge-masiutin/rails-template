# Create an app from the template

[Create a repository on GitHub](https://github.com/serge-masiutin/rails-template/generate), then clone it.
GitHub creates an independent history. Future template changes are not applied automatically.

## App name and Android ID

From a clean checkout, before `bin/setup` or the first Rails boot:

```sh
mise exec -- bin/configure --name my_app --android-id com.example.myapp --dry-run
mise exec -- bin/configure --name my_app --android-id com.example.myapp
```

`--name` accepts snake_case, up to 36 characters. `my_app` produces Ruby namespace `MyApp`,
prefix `myapp`, and databases `my_app_development`, `my_app_test`, and `my_app_production`.
Use your own `--android-id`, such as `com.acme.portal`. Debug builds append `.debug`.
The initial display name matches the Ruby namespace; edit UI translations after setup.

The command updates source files, Kotlin paths, class/resource names, configuration, metrics,
tests, documentation, and working skills. Vendored sources, fonts, licenses, and their hashes stay intact.
It does not change Git remotes, identity, keys, or machine settings.

Choices are saved in `config/template.json`. Repeating the same choices is a no-op.
Renaming an already configured app is rejected: migrating databases and a published Android ID
requires a separate plan.

Review `git diff`, run `bin/setup --skip-server` and `bin/ci`, then commit.
GitHub CI configures a sample while the repository is an unconfigured template;
after personalization it checks your app.

## First account

After `bin/setup`, open `mise exec -- bin/rails console`:

```ruby
require "io/console"
User.create!(email_address: "you@example.com", password: IO.console.getpass("Password (at least 12 characters): "))
```

Self-registration is not enabled. Grant the admin role with
`mise exec -- bin/rails admin:grant EMAIL=you@example.com`, then open `/admin`.
Development email is saved in `tmp/mail`. See the [access contract](observability.md#admin).

## Local environment and release

- `bin/setup` generates fresh operations, AnyCable, and imgproxy secrets. Do not copy them between apps.
- Configure Git name/email and, if needed, `core.sshCommand` with `git config --local`.
- Set domains, SMTP, secrets, and registry during [deployment](deployment.md). The template contains no production credentials.
- AI stays disabled until you choose a provider, model, and key. Product AI features require their own evals.
- Before production, configure backups, verify restoration and SMTP, and connect an alert receiver.
- Verify Android navigation on a device and sign Release builds with your own keystore.

When running multiple apps, allocate separate local ports, Prometheus targets, databases,
and volumes. See [observability](observability.md).
