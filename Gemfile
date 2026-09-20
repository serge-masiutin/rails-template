source "https://rubygems.org"

ruby file: ".ruby-version"

gem "rails", "8.1.3.1"
# Rails 8.1 passes positional options to JSON.parse: rails/rails#58685.
gem "json", "< 3"
gem "propshaft"
gem "pg", "~> 1.6"
gem "puma", "~> 8.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails", "~> 4.0"
gem "bcrypt", "~> 3.1"
gem "anyway_config", "~> 2.7"
gem "action_policy", "~> 0.7.7"
gem "active_delivery", "~> 1.2"
gem "after_commit_everywhere", "~> 1.6"
gem "ruby_llm", "~> 2.0"
gem "activeagent", "~> 1.6"
# Prometheus DirectFileStore requires CGI.parse, removed from Ruby 4 stdlib.
gem "cgi", "~> 0.5"
gem "view_component", "~> 4.0"
gem "solid_cache"
gem "solid_queue"
gem "anycable-rails-core", "~> 1.6"
gem "rails_semantic_logger", "~> 5.2"
gem "mission_control-jobs", "~> 1.3"
gem "yabeda-rails", "~> 0.11"
gem "yabeda-prometheus", "~> 0.9"
gem "bootsnap", ">= 1.24.4", require: false
gem "kamal", "~> 2.12", require: false
gem "thruster", require: false
gem "image_processing", "~> 2.1"
# ImageProcessing 2 requires an explicit Active Storage analysis adapter.
gem "ruby-vips", "~> 2.3"
gem "imgproxy-rails", "~> 0.3"
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-thread_safety", require: false
  gem "rubocop-md", "~> 2.0", require: false
  gem "herb", require: false
  gem "isolator", "~> 1.2", require: false
  # Isolator's Sniffer adapter requires benchmark, removed from Ruby 4 stdlib.
  gem "benchmark", "~> 0.5", require: false
end

group :development do
  gem "ruby-lsp", "~> 0.26", require: false
  gem "ruby-lsp-rails", "~> 0.4", require: false
  gem "lefthook", "~> 2.1", require: false
  gem "web-console"
  gem "lookbook", "~> 2.3"
end

group :test do
  gem "test-prof", "~> 1.6", require: "test_prof"
  gem "stackprof", "~> 0.2", require: false
  gem "capybara"
  gem "cuprite"
  gem "webmock"
  gem "n_plus_one_control", "~> 0.8", require: false
end
