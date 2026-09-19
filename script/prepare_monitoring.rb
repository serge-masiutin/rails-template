abort "Локальный мониторинг запускается только в development" unless Rails.env.development?
config = Rails.application.config.x.operations
abort "Сначала задайте metrics_token в config/operations.local.yml" unless config.metrics_configured?

path = Rails.root.join("tmp/observability")
FileUtils.mkdir_p(path, mode: 0o700)
FileUtils.chmod(0o700, path)
# Родительский каталог закрыт на хосте; отдельный bind mount читается непривилегированным контейнером.
File.write(path.join("metrics_token"), config.metrics_token, perm: 0o644)
