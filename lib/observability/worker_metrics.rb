require "puma"

module Observability
  class WorkerMetrics
    PORT = 9394

    def self.call(env)
      if env.fetch("PATH_INFO") == "/metrics" && env.fetch("REQUEST_METHOD") == "GET"
        Operations::MetricsController.action(:workers).call(env)
      else
        [ 404, { "content-type" => "text/plain" }, [ "Not found" ] ]
      end
    end

    def self.start
      server = Puma::Server.new(self, nil, min_threads: 0, max_threads: 1)
      server.add_tcp_listener(Rails.env.production? ? "0.0.0.0" : "127.0.0.1", PORT)
      server.run
      server
    end
  end
end
