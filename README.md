# Rails Template

A Rails and Hotwire starter for web and Android apps. Includes authentication,
an admin area, background jobs, AnyCable, imgproxy, and AI tooling.
Overmind runs local processes; Kamal deploys the app; GitHub Actions runs CI.

## Create an app

[Use this template](https://github.com/serge-masiutin/rails-template/generate), then clone your repository.
On macOS, install Homebrew, Docker, and Chrome. Start Docker and run:

```sh
brew bundle
mise install
mise exec -- bin/configure --name my_app --android-id com.example.myapp
mise exec -- bin/setup --skip-server
mise exec -- bin/dev
```

Choose your own app name and Android ID before the first setup.
[Create an administrator](docs/template.md#first-account).

[App](http://localhost:3000) · [Admin](http://localhost:3000/admin) ·
[Grafana](http://localhost:3001) · [Prometheus](http://localhost:9090)

`bin/dev` also starts Loki and Alloy for logs. Admin panels update through AnyCable;
Prometheus collects metrics independently. The UI ships in English with Rails i18n ready for more languages.
Run checks with `mise exec -- bin/ci`. `Ctrl+C` stops Overmind;
[stop infrastructure containers separately](docs/observability.md#local-development).

## Documentation

- [Template setup](docs/template.md) · [Development](docs/development.md) · [Testing](docs/testing.md)
- [Architecture and i18n](docs/architecture.md) · [Hotwire](docs/hotwire.md) · [Android](docs/native.md)
- [Monitoring and logs](docs/observability.md) · [Deployment](docs/deployment.md)
- [AnyCable](docs/realtime.md) · [Images](docs/images.md) · [Active Agent and AgentPrism](docs/agents.md)
- [Agent rules](AGENTS.md) · [Skills](docs/agent-skills.md)

Based on the Evil Martians [Rails Startup Stack](https://evilmartians.com/rails-startup-stack) and agent skills.
[MIT](LICENSE) · [Third-party licenses](THIRD_PARTY.md).
