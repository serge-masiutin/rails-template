# Граница SDK → БД: разрешены только идентификаторы, время, статусы и числовой usage.
class AgentTrace::Document
  class InvalidTrace < StandardError; end

  TYPES = { "root" => "agent_invocation", "prompt" => "chain_operation", "llm" => "llm_call",
    "tool" => "tool_execution", "thinking" => "span", "embedding" => "embedding", "error" => "event" }.freeze
  STATUSES = { "OK" => "success", "ERROR" => "error", "UNSET" => "warning" }.freeze
  LABELS = %w[agent.class agent.action starterapp.prompt_version starterapp.provider starterapp.model
    starterapp.request_id starterapp.job_id tool.name error.type llm.finish_reason].freeze
  USAGE = %w[input output cached cache_creation reasoning].freeze
  MAX_SPANS = 256

  def initialize(trace)
    @trace = trace
  end

  def attributes
    valid!(@trace.is_a?(Hash))
    id = identifier(@trace.fetch("trace_id"))
    originals = @trace.fetch("spans")
    valid!(originals.is_a?(Array) && originals.size.between?(1, MAX_SPANS))
    valid!(originals.all? { |span| span.is_a?(Hash) && span.fetch("attributes").is_a?(Hash) })
    roots = originals.select { |span| span.fetch("parent_span_id").nil? }
    valid!(roots.one?)
    root = roots.fetch(0)
    indexed = originals.index_by { |span| identifier(span.fetch("span_id")) }
    valid!(indexed.size == originals.size)
    children = originals.group_by { |span| span.fetch("parent_span_id") }
    visited = []
    spans = [ convert(root, children, visited, depth: 0) ]
    valid!(visited.size == originals.size)
    first = spans.fetch(0)
    started = Time.iso8601(first.fetch(:startTime))
    record = { id: id, name: first.fetch(:title), spansCount: visited.size,
      durationMs: first.fetch(:duration), startTime: (started.to_f * 1000).round,
      agentDescription: "Active Agent · #{first.fetch(:status)}" }
    record[:totalTokens] = first.fetch(:tokensCount) if first.key?(:tokensCount)
    { trace_id: id, started_at: started, document: { traceRecord: record, spans: spans } }
  rescue KeyError, TypeError, ArgumentError
    raise InvalidTrace, "Некорректный контракт трассы Active Agent"
  end

  private

  def convert(span, children, visited, depth:)
    valid!(depth < 32)
    id = identifier(span.fetch("span_id"))
    valid!(!visited.include?(id))
    visited << id
    started = Time.iso8601(span.fetch("start_time"))
    ended = Time.iso8601(span.fetch("end_time"))
    valid!(ended >= started)
    attributes = span.fetch("attributes").slice(*LABELS).transform_values { |value| identifier(value) }
    type = TYPES.fetch(span.fetch("type"))
    title = case type
    when "agent_invocation" then [ attributes.fetch("agent.class"), attributes.fetch("agent.action") ].join(".")
    when "tool_execution" then "tool.#{attributes.fetch('tool.name')}"
    else span.fetch("type")
    end
    result = { id: id, title: title, type: type, status: STATUSES.fetch(span.fetch("status")),
      startTime: started.iso8601(6), endTime: ended.iso8601(6), duration: ((ended - started) * 1000).round(3),
      attributes: attributes.map { |key, value| { key: key, value: { stringValue: value } } } }
    usage = span.fetch("attributes").slice(*USAGE.map { |key| "starterapp.usage.#{key}" })
    usage.each_value { |value| valid!(value.is_a?(Integer) && value >= 0) }
    if usage.any?
      result[:metadata] = usage
      # Reasoning уже входит в output; cached input RubyLLM 2 выделяет отдельно.
      if usage.key?("starterapp.usage.input") && usage.key?("starterapp.usage.output")
        result[:tokensCount] = usage.fetch("starterapp.usage.input") + usage.fetch("starterapp.usage.output") +
          usage.fetch("starterapp.usage.cached", 0) + usage.fetch("starterapp.usage.cache_creation", 0)
      end
    end
    result[:raw] = JSON.generate(result.merge(statusMessage: attributes["error.type"]).compact)
    result[:children] = children.fetch(id, []).map { |child| convert(child, children, visited, depth: depth + 1) }
    result
  end

  def identifier(value)
    valid!(value.is_a?(String) && value.match?(/\A[A-Za-z0-9_:.,\/\-]{1,160}\z/))
    value
  end

  def valid!(condition)
    raise InvalidTrace, "Некорректный контракт трассы Active Agent" unless condition
  end
end
