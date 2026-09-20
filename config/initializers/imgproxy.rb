unless ENV["SECRET_KEY_BASE_DUMMY"]
  %i[key salt].each do |name|
    value = Imgproxy.config.public_send(name)
    unless value && /\A[0-9a-fA-F]{64}\z/.match?(value)
      raise "IMGPROXY_#{name.upcase}: expected 32 hex-encoded bytes; run bin/images setup locally"
    end
  end
end

unless Imgproxy.config.endpoint == "/images"
  raise "IMGPROXY_ENDPOINT must be /images, the shared path for web, Android, and Kamal"
end

Rails.application.config.active_storage.resolve_model_to_route = :starterapp_image
Rails.application.config.active_storage.urls_expire_in = 15.minutes
