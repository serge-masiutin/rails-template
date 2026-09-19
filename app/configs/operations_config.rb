class OperationsConfig < Anyway::Config
  attr_config :username, :password, :metrics_token

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
  end

  def metrics_configured?
    metrics_token.present?
  end

  def configured?
    username.present? && password.present?
  end
end
