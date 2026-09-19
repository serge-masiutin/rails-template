module Observability
  class ErrorSubscriber
    LEVELS = { error: :error, warning: :warn, info: :info }.freeze

    def report(error, handled:, severity:, context:, source: nil)
      SemanticLogger.named_tagged(request_id: Current.request_id) do
        Rails.logger.public_send(LEVELS.fetch(severity), message: "Application error", exception: error,
          payload: { event: "error.reported", handled: handled, source: source })
      end
    end
  end
end
