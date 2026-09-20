module RequestCorrelatedJob
  extend ActiveSupport::Concern

  included do
    attr_accessor :request_id
    around_perform :with_request_context
  end

  def serialize
    self.request_id ||= Current.request_id
    super.merge("request_id" => request_id)
  end

  def deserialize(job_data)
    super
    # Older and scheduled jobs may have no HTTP context.
    self.request_id = job_data["request_id"]
  end

  private

  def with_request_context(&block)
    # Jobs receive users explicitly, including perform_now calls inside HTTP requests.
    Current.set(session: nil, request_id: request_id) do
      SemanticLogger.named_tagged(request_id: request_id, job_id: job_id, &block)
    end
  end
end
