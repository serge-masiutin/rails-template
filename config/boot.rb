ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
require "bootsnap/setup"
# On Ruby 4.0.4+, Bootsnap replaces Freezolite without changing dependency code.
Bootsnap.enable_frozen_string_literal(app_only: true)
