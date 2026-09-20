class Llm
  def self.build_chat(settings: Rails.configuration.x.llm)
    settings.ensure_configured!
    context = RubyLLM.context do |config|
      config.public_send("#{settings.provider_key}=", settings.api_key)
      config.request_timeout = settings.request_timeout
    end
    context.chat(model: settings.model, provider: settings.provider)
  end
end
