ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
require "bootsnap/setup"
# Ruby 4.0.4+ lets Bootsnap freeze application strings without changing dependency code.
Bootsnap.enable_frozen_string_literal(app_only: true)
