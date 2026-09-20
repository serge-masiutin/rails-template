abort "Local monitoring requires the development environment" unless Rails.env.development?
config = Rails.application.config.x.operations
abort "Set metrics_token in config/operations.local.yml first" unless config.metrics_configured?

path = Rails.root.join("tmp/observability")
FileUtils.mkdir_p(path, mode: 0o700)
FileUtils.chmod(0o700, path)
# The host directory stays private; its bind mount must be readable by the unprivileged container.
File.write(path.join("metrics_token"), config.metrics_token, perm: 0o644)
