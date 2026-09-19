ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
require "bootsnap/setup"
# В Ruby 4.0.4+ Bootsnap заменяет Freezolite; код зависимостей не меняем.
Bootsnap.enable_frozen_string_literal(app_only: true)
