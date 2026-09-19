require "net/http"

module Realtime
  # Штатный HTTP adapter пишет payload в лог и скрывает сбой в отдельном потоке.
  # Здесь публикация синхронная: вызывающий код получает ошибку, TLS проверяется.
  class HttpBroadcaster < AnyCable::BroadcastAdapters::Base
    class Error < StandardError; end

    def initialize(url: AnyCable.config.http_broadcast_url, secret: AnyCable.config.broadcast_key!)
      @uri = URI(url)
      raise ArgumentError, "Ожидается HTTP(S) URL AnyCable" unless @uri.is_a?(URI::HTTP)
      @secret = secret
    end

    def raw_broadcast(payload)
      request = Net::HTTP::Post.new(@uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{@secret}")
      request.body = payload
      response = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == "https",
        open_timeout: 2, read_timeout: 5, write_timeout: 5, max_retries: 0) { |http| http.request(request) }
      raise Error, "AnyCable отклонил публикацию: HTTP #{response.code}" unless response.code == "201"
    end
  end
end
