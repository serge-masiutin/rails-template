# Imgproxy::Config уже использует Anyway Config: YAML, локальный файл и ENV.
unless ENV["SECRET_KEY_BASE_DUMMY"]
  %i[key salt].each do |name|
    value = Imgproxy.config.public_send(name)
    unless value && /\A[0-9a-fA-F]{64}\z/.match?(value)
      raise "IMGPROXY_#{name.upcase}: нужны 32 байта в hex; локально выполни bin/images setup"
    end
  end
end

unless Imgproxy.config.endpoint == "/images"
  raise "IMGPROXY_ENDPOINT должен быть /images: путь общий для веба, Android и Kamal"
end

Rails.application.config.active_storage.resolve_model_to_route = :starterapp_image
Rails.application.config.active_storage.urls_expire_in = 15.minutes
