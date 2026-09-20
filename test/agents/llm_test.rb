require "test_helper"

class LlmTest < ActiveSupport::TestCase
  test "missing settings fail before network IO" do
    assert_raises(Anyway::Config::ValidationError) do
      Llm.build_chat(settings: LlmConfig.new(api_key: nil))
    end
  end

  test "partial configuration and invalid values are rejected" do
    assert_raises(Anyway::Config::ValidationError) { LlmConfig.new(provider: "openai", model: nil, api_key: nil) }
    assert_raises(Anyway::Config::ValidationError) { settings(provider: "unknown") }
    assert_raises(Anyway::Config::ValidationError) { settings(request_timeout: 0) }
  end

  test "provider error is visible without repeating the request" do
    previous_key = RubyLLM.config.gemini_api_key
    request = stub_request(:post, "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent")
      .with(headers: { "x-goog-api-key" => "test-api-key" })
      .to_return(status: 503, headers: { "Content-Type" => "application/json" }, body: '{"error":{"message":"Unavailable","status":"UNAVAILABLE","code":503}}')

    assert_raises(RubyLLM::ServiceUnavailableError) { Llm.build_chat(settings: settings).ask("Probe") }
    assert_requested request, times: 1
    assert RubyLLM.config.gemini_api_key.equal?(previous_key), "The global API key changed"
  end

  private

  def settings(**overrides)
    LlmConfig.new(**{ api_key: "test-api-key", request_timeout: 5 }.merge(overrides))
  end
end
