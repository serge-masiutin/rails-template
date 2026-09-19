require "test_helper"
require "concurrent"

class ApplicationAgentTest < ActiveJob::TestCase
  self.use_transactional_tests = false

  class ProbeAgent < ApplicationAgent
    PROMPT_VERSION = "1"
    prepend_view_path Rails.root.join("test/fixtures/agents")

    def lookup
      prompt message: "Тестовая инструкция", instructions: "Тестовая инструкция", max_tool_turns: 2,
        tools: [ { type: "function", function: { name: "lookup_record", description: "Read a record",
          parameters: { type: "object", properties: { query: { type: "string" } }, required: [ "query" ] } } } ]
    end

    def lookup_record(query:)
      raise ArgumentError, "PRIVATE_TOOL_ERROR" if query == "fail"

      "PRIVATE_TOOL_RESULT"
    end

    def summarize(text:)
      @text = text
      prompt instructions: true
    end
  end

  def setup
    super
    AgentTrace.delete_all
    @previous_settings = Rails.configuration.x.llm
    @previous_key = RubyLLM.config.openai_api_key
    @previous_timeout = RubyLLM.config.request_timeout
    Rails.configuration.x.llm = LlmConfig.new(provider: "openai", model: "gpt-4.1-mini",
      api_key: "agent-test-key", request_timeout: 5)
    load Rails.root.join("config/initializers/ruby_llm.rb")
    @log = StringIO.new
    @appender = SemanticLogger.add_appender(io: @log, formatter: Observability::JsonFormatter.new)
  end

  def teardown
    AgentTrace.delete_all
    Rails.configuration.x.llm = @previous_settings
    RubyLLM.config.openai_api_key = @previous_key
    RubyLLM.config.request_timeout = @previous_timeout
    SemanticLogger.remove_appender(@appender)
    Current.reset
    super
  end

  test "ERB-промпт отправляется через RubyLLM с явной моделью и отдельным контекстом" do
    request = stub_completion
    labels = { agent: ProbeAgent.name, action: "summarize", direction: :input }
    previous_tokens = Yabeda.starterapp.agent_tokens.get(labels) || 0
    first = ProbeAgent.summarize(text: "PRIVATE_INPUT").generate_now
    second = ProbeAgent.summarize(text: "OTHER_INPUT").generate_now

    assert_equal "PRIVATE_OUTPUT", first.message.content
    assert_equal 12, first.usage.input_tokens
    assert_equal 4, second.usage.output_tokens
    assert_equal "stop", first.finish_reason
    assert_equal 2, AgentTrace.count
    trace = AgentTrace.order(:id).last.document
    assert_equal 3, trace.dig("traceRecord", "spansCount")
    assert_equal 16, trace.dig("traceRecord", "totalTokens")
    assert_equal %w[chain_operation llm_call], trace.fetch("spans").first.fetch("children").map { |span| span.fetch("type") }
    %w[PRIVATE_INPUT OTHER_INPUT PRIVATE_OUTPUT agent-test-key].each { |secret| refute_includes trace.to_json, secret }
    assert_requested request, times: 2
    assert_requested(:post, endpoint, times: 1) do |http|
      body = JSON.parse(http.body)
      body.fetch("model") == "gpt-4.1-mini" && http.body.include?("OTHER_INPUT") && !http.body.include?("PRIVATE_INPUT")
    end
    record = agent_records.last
    assert_equal "1", record.dig("payload", "prompt_version")
    assert_equal 12, record.dig("payload", "usage", "input")
    assert_equal "ok", record.dig("payload", "status")
    assert_equal previous_tokens + 24, Yabeda.starterapp.agent_tokens.get(labels)
    %w[PRIVATE_INPUT OTHER_INPUT PRIVATE_OUTPUT agent-test-key].each { |secret| refute_includes @log.string, secret }
  end

  test "реальный цикл инструмента записывает span без аргументов и результата" do
    final = { id: "resp_done", object: "response", status: "completed", model: "gpt-4.1-mini",
      output: [ { id: "msg_done", type: "message", role: "assistant", status: "completed",
        content: [ { type: "output_text", text: "PRIVATE_OUTPUT", annotations: [] } ] } ],
      usage: { input_tokens: 12, output_tokens: 4, total_tokens: 16 } }
    tool = final.merge(output: [ { type: "function_call", id: "fc_1", call_id: "call_1",
      name: "lookup_record", arguments: { query: "PRIVATE_QUERY" }.to_json, status: "completed" } ])
    request = stub_request(:post, endpoint).to_return(
      { headers: { "Content-Type" => "application/json" }, body: tool.to_json },
      { headers: { "Content-Type" => "application/json" }, body: final.to_json })
    ProbeAgent.lookup.generate_now
    assert_requested request, times: 2
    trace = AgentTrace.last.document
    tool_span = trace.fetch("spans").first.fetch("children").find { |span| span.fetch("type") == "llm_call" }.fetch("children").first
    assert_equal "tool.lookup_record", tool_span.fetch("title")
    assert_equal "success", tool_span.fetch("status")
    refute_includes trace.to_json, "PRIVATE_"
    SemanticLogger.flush
    refute_includes @log.string, "PRIVATE_"
  end

  test "одновременные генерации изолируют traces и освобождают контекст" do
    barrier = Concurrent::CyclicBarrier.new(2)
    stub_completion(barrier: barrier)
    threads = 2.times.map do |index|
      Thread.new do # rubocop:disable ThreadSafety/NewThread
        Rails.application.executor.wrap do
          Current.request_id = "concurrent-#{index}"
          ProbeAgent.summarize(text: "PRIVATE_#{index}").generate_now
          ActiveAgent::Telemetry.tracer.current_span
        end
      end
    end
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      threads.each do |thread|
        raise Timeout::Error, "Генерация не завершилась" unless thread.join(10)
        assert_nil thread.value
      end
    end
    assert_equal 2, AgentTrace.count
    requests = AgentTrace.all.map do |trace|
      trace.document.fetch("spans").first.fetch("attributes").find { |item| item.fetch("key") == "starterapp.request_id" }.fetch("value").fetch("stringValue")
    end
    assert_equal %w[concurrent-0 concurrent-1], requests.sort
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
    threads&.each(&:join)
  end

  test "без конфигурации или версии промпта генерация завершается до сети" do
    Rails.configuration.x.llm = LlmConfig.new(provider: nil, model: nil, api_key: nil)
    assert_raises(Anyway::Config::ValidationError) { ProbeAgent.summarize(text: "private").generate_now }
    Rails.configuration.x.llm = LlmConfig.new(provider: "openai", model: "gpt-4.1-mini", api_key: "agent-test-key")
    assert_raises(NameError) { ApplicationAgent.prompt(message: "private").generate_now }
    assert_not_requested :post, endpoint
  end

  test "адаптер сохраняет кэш и reasoning из RubyLLM 2" do
    stub_completion(usage: { input_tokens: 12, output_tokens: 4, total_tokens: 16,
      input_tokens_details: { cached_tokens: 4 }, output_tokens_details: { reasoning_tokens: 1 } })
    response = ProbeAgent.summarize(text: "PRIVATE_INPUT").generate_now
    assert_equal 8, response.usage.input_tokens
    assert_equal 4, response.usage.output_tokens
    assert_equal 4, response.usage.cached_tokens
    assert_equal 1, response.usage.reasoning_tokens
    assert_equal 16, AgentTrace.last.document.dig("traceRecord", "totalTokens")
  end

  test "отсутствующий usage не подменяется нулевым расходом" do
    stub_completion(usage: nil)
    response = ProbeAgent.summarize(text: "PRIVATE_INPUT").generate_now
    assert_nil response.usage
    refute AgentTrace.last.document.fetch("traceRecord").key?("totalTokens")
    refute agent_records.last.fetch("payload").key?("usage")
  end

  test "генерация запускается после commit с request_id и без секретов в очереди" do
    request = stub_completion
    Current.request_id = "agent-request"
    User.transaction do
      User.count
      assert_no_enqueued_jobs { ProbeAgent.summarize(text: "PRIVATE_INPUT").generate_later }
    end
    assert_enqueued_jobs 1, only: AgentGenerationJob
    serialized = enqueued_jobs.last
    assert_equal "agents", serialized.fetch(:queue)
    assert_equal "agent-request", serialized.fetch("request_id")
    refute_includes serialized.fetch("arguments").to_json, "agent-test-key"
    Current.reset
    perform_enqueued_jobs(only: AgentGenerationJob)
    assert_requested request, times: 1
    record = agent_records.last
    assert_equal "agent-request", record.dig("named_tags", "request_id")
    assert_equal serialized.fetch("job_id"), record.dig("named_tags", "job_id")
    attributes = AgentTrace.last.document.fetch("spans").first.fetch("attributes")
    assert_includes attributes, { "key" => "starterapp.request_id", "value" => { "stringValue" => "agent-request" } }
    assert_includes attributes, { "key" => "starterapp.job_id", "value" => { "stringValue" => serialized.fetch("job_id") } }
    assert_nil Current.request_id
    assert_empty SemanticLogger.named_tags
  end

  test "rollback отменяет генерацию" do
    assert_no_enqueued_jobs do
      User.transaction do
        User.count
        ProbeAgent.summarize(text: "private").generate_later
        raise ActiveRecord::Rollback
      end
    end
    assert_not_requested :post, endpoint
  end

  test "синхронная генерация внутри транзакции запрещена" do
    stub_completion
    assert_raises(Isolator::HTTPError) do
      User.transaction do
        User.count
        ProbeAgent.summarize(text: "PRIVATE_INPUT").generate_now
      end
    end
  end

  test "ошибка провайдера сохраняется без скрытого повтора и утечки текста" do
    request = stub_request(:post, endpoint).to_return(status: 503,
      headers: { "Content-Type" => "application/json" },
      body: { error: { message: "PRIVATE_ERROR", type: "server_error" } }.to_json)

    job = ProbeAgent.summarize(text: "PRIVATE_INPUT").generate_later
    clear_enqueued_jobs
    error = assert_raises(ActiveAgent::Providers::Errors::ServiceUnavailable) { job.perform_now }
    assert_kind_of RubyLLM::ServiceUnavailableError, error.cause
    assert_requested request, times: 1
    assert_no_enqueued_jobs
    assert_equal "error", agent_records.last.dig("payload", "status")
    assert_nil Current.request_id
    assert_empty SemanticLogger.named_tags
    trace = AgentTrace.last.document
    assert_equal "error", trace.fetch("spans").first.fetch("status")
    %w[PRIVATE_INPUT PRIVATE_ERROR agent-test-key].each { |secret| refute_includes trace.to_json, secret }
    %w[PRIVATE_INPUT PRIVATE_ERROR agent-test-key].each { |secret| refute_includes @log.string, secret }
  end

  test "телеметрия и веб-консоль не публикуют тексты" do
    assert ActiveAgent::Telemetry.enabled?
    assert_nil ActiveAgent::Telemetry.configuration.endpoint
    assert_nil ActiveAgent::Telemetry.configuration.api_key
    assert_not ActiveAgent::Telemetry.configuration.capture_bodies
    assert_not Rails.configuration.active_agent.show_previews
    refute Rails.application.routes.routes.any? { |route| route.path.spec.to_s.start_with?("/rails/agents") }
  end

  private

  def endpoint = "https://api.openai.com/v1/responses"

  def stub_completion(usage: { input_tokens: 12, output_tokens: 4, total_tokens: 16 }, barrier: nil)
    stub_request(:post, endpoint)
      .with(headers: { "Authorization" => "Bearer agent-test-key" }) { |request| request.body.include?("Тестовая инструкция") }
      .to_return do
        raise Timeout::Error, "HTTP-вызовы не достигли барьера" if barrier && !barrier.wait(5)
        { headers: { "Content-Type" => "application/json" }, body: {
        id: "resp_test", object: "response", status: "completed", model: "gpt-4.1-mini",
        output: [ { id: "msg_test", type: "message", role: "assistant", status: "completed",
          content: [ { type: "output_text", text: "PRIVATE_OUTPUT", annotations: [] } ] } ],
        usage: usage
        }.to_json }
      end
  end

  def agent_records
    SemanticLogger.flush
    @log.string.lines.map { |line| JSON.parse(line) }.select { |record| record.dig("payload", "event") == "agent.generated" }
  end
end
