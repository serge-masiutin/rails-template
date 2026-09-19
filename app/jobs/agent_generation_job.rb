# Сохраняет контракт Active Agent и контекст обычных заданий StarterApp.
class AgentGenerationJob < ActiveAgent::GenerationJob
  include RequestCorrelatedJob

  self.enqueue_after_transaction_commit = true
end
