unless Rails.env.test? || ENV["SECRET_KEY_BASE_DUMMY"]
  unless AnyCable.config.secret && AnyCable.config.secret.length >= 64
    raise "Set ANYCABLE_SECRET (at least 64 characters); run bin/cable setup locally"
  end
end

require Rails.root.join("lib/realtime/http_broadcaster")
AnyCable.broadcast_adapter = Realtime::HttpBroadcaster.new

Rails.application.config.action_cable.logger = SemanticLogger["ActionCable"].tap { |logger| logger.level = :warn }
Rails.application.config.action_cable.allowed_request_origins = if Rails.env.production?
  [ "https://#{Rails.configuration.x.web.host}" ]
elsif Rails.env.test?
  [ "http://127.0.0.1:3100", "http://localhost:3100" ]
else
  [ "http://localhost:3000", "http://127.0.0.1:3000", "http://10.0.2.2:3000",
    "http://#{Rails.configuration.x.web.host}:3000" ].uniq
end
