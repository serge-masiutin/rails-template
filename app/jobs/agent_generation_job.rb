class AgentGenerationJob < ActiveAgent::GenerationJob
  include RequestCorrelatedJob

  self.enqueue_after_transaction_commit = true
end
