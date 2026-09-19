abort "Local monitoring requires development" unless Rails.env.development?
config = Rails.application.config.x.operations
abort "Set metrics_token in config/operations.local.yml first" unless config.metrics_configured?

path = Rails.root.join("tmp/observability")
FileUtils.mkdir_p(path, mode: 0o700)
FileUtils.chmod(0o700, path)
# The parent directory is private on the host; a separate bind mount is readable by the unprivileged container.
File.write(path.join("metrics_token"), config.metrics_token, perm: 0o644)
