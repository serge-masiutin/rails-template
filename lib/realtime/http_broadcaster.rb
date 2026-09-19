require "net/http"

module Realtime
  # The standard HTTP adapter logs payloads and hides failures in another thread.
  # Publish synchronously so callers receive errors; verify TLS.
  class HttpBroadcaster < AnyCable::BroadcastAdapters::Base
    class Error < StandardError; end

    def initialize(url: AnyCable.config.http_broadcast_url, secret: AnyCable.config.broadcast_key!)
      @uri = URI(url)
      raise ArgumentError, "Expected an HTTP(S) AnyCable URL" unless @uri.is_a?(URI::HTTP)
      @secret = secret
    end

    def raw_broadcast(payload)
      request = Net::HTTP::Post.new(@uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{@secret}")
      request.body = payload
      response = Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == "https",
        open_timeout: 2, read_timeout: 5, write_timeout: 5, max_retries: 0) { |http| http.request(request) }
      raise Error, "AnyCable rejected the broadcast: HTTP #{response.code}" unless response.code == "201"
    end
  end
end
