require "test_helper"

class LlmTest < ActiveSupport::TestCase
  test "missing settings fail before network IO" do
    assert_raises(Anyway::Config::ValidationError) do
      Llm.build_chat(settings: LlmConfig.new(provider: nil, model: nil, api_key: nil))
    end
  end

  test "partial configuration and invalid values are rejected" do
    assert_raises(Anyway::Config::ValidationError) { LlmConfig.new(provider: "openai", model: nil, api_key: nil) }
    assert_raises(Anyway::Config::ValidationError) { settings(provider: "unknown") }
    assert_raises(Anyway::Config::ValidationError) { settings(request_timeout: 0) }
  end

  test "conversations are isolated and models use the local registry" do
    first = Llm.build_chat(settings: settings)
    second = Llm.build_chat(settings: settings)
    assert_not_same first, second
    assert_equal "gpt-4.1-mini", first.model.id
    assert_raises(RubyLLM::ModelNotFoundError) { Llm.build_chat(settings: settings(model: "starterapp-nonexistent-model")) }
  end

  test "provider error is visible without repeating the request" do
    request = stub_request(:post, "https://api.openai.com/v1/responses")
      .with(headers: { "Authorization" => "Bearer test-api-key" })
      .to_return(status: 503, headers: { "Content-Type" => "application/json" }, body: '{"error":{"message":"Unavailable","type":"server_error"}}')

    assert_raises(RubyLLM::ServiceUnavailableError) { Llm.build_chat(settings: settings).ask("Probe") }
    assert_requested request, times: 1
    assert_nil RubyLLM.config.openai_api_key
    assert_not RubyLLM.logger.debug?
    assert_not RubyLLM.config.log_stream_debug
  end

  private

  def settings(**overrides)
    LlmConfig.new(**{ provider: "openai", model: "gpt-4.1-mini", api_key: "test-api-key", request_timeout: 5 }.merge(overrides))
  end
end
