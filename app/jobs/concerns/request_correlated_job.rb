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
    # Старые задания и задания планировщика могут не иметь HTTP-контекста.
    self.request_id = job_data["request_id"]
  end

  private

  def with_request_context(&block)
    # Задание получает пользователя явно аргументом, включая вызов perform_now из HTTP.
    Current.set(session: nil, request_id: request_id) do
      SemanticLogger.named_tagged(request_id: request_id, job_id: job_id, &block)
    end
  end
end
