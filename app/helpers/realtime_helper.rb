module RealtimeHelper
  def realtime_url
    return AnyCable.config.websocket_url unless Rails.env.development?

    # Android-эмулятор открывает приложение через 10.0.2.2, браузер — через localhost.
    URI::Generic.build(scheme: "ws", host: request.host, port: 8080, path: "/cable").to_s
  end
end
