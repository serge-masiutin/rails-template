class WebConfig < Anyway::Config
  attr_config :host, protocol: "https", port: 443
  coerce_types port: :integer
  required :host

  on_load do
    raise_validation_error("protocol: expected http or https") unless %w[http https].include?(protocol)
    raise_validation_error("port: expected 1..65535") unless (1..65_535).cover?(port)
    raise_validation_error("host: expected a hostname without path or port") unless /\A[a-zA-Z0-9.-]+\z/.match?(host)
  end

  def url_options
    { host: host, protocol: protocol, port: port }
  end
end
