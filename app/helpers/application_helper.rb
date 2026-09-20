module ApplicationHelper
  def realtime_url
    return AnyCable.config.websocket_url unless Rails.env.development?

    # Android emulator uses 10.0.2.2; the browser uses localhost.
    URI::Generic.build(scheme: "ws", host: request.host, port: 8080, path: "/cable").to_s
  end
end
