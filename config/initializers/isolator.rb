if Rails.env.development? || Rails.env.test?
  Isolator.configure do |config|
    config.raise_exceptions = true
  end
end
