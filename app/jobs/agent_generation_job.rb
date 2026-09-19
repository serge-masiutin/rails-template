# Preserve the Active Agent contract and shared application job context.
class AgentGenerationJob < ActiveAgent::GenerationJob
  include RequestCorrelatedJob

  self.enqueue_after_transaction_commit = true
end
