require "test_helper"
require "capybara/cuprite"

# Пул очереди создаётся до fixtures: транзакция должна открыться и закрыться
# в потоке теста, а не впервые открыться при запросе Mission Control из Puma.
SolidQueue::Record.connection_pool

Capybara.register_driver :cuprite do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [ 1280, 900 ], js_errors: true,
    timeout: 10, process_timeout: 20, browser_options: { "no-sandbox" => nil })
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
