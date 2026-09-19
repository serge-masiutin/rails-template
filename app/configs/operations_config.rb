class OperationsConfig < Anyway::Config
  attr_config :username, :password, :metrics_token, :grafana_url, :prometheus_url, :logs_url

  on_load do
    if username.present? != password.present?
      raise_validation_error("username и password задаются вместе")
    end
    if metrics_token.present? && metrics_token.length < 32
      raise_validation_error("metrics_token: нужно не менее 32 символов")
    end
    if password.present? && password.length < 32
      raise_validation_error("password: нужно не менее 32 символов")
    end
    %i[grafana_url prometheus_url logs_url].each do |attribute|
      value = public_send(attribute)
      next if value.blank?

      begin
        uri = URI.parse(value)
      rescue URI::InvalidURIError
        raise_validation_error("#{attribute}: некорректный URL")
      end
      unless uri.is_a?(URI::HTTP) && uri.host.present? && uri.userinfo.nil? && (!Rails.env.production? || uri.scheme == "https")
        raise_validation_error("#{attribute}: нужен HTTP(S) URL без учётных данных; в production только HTTPS")
      end
    end
  end

  def metrics_configured?
    metrics_token.present?
  end

  def configured?
    username.present? && password.present?
  end
end
