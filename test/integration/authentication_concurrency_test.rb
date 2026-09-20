require "test_helper"
require "concurrent"

Rails.application.eager_load!
Rails.application.reload_routes_unless_loaded

class AuthenticationConcurrencyTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  setup do
    @user = User.create!(email_address: "concurrent-#{SecureRandom.hex(8)}@example.test", password: "old-password-2026")
  end

  teardown do
    @user.destroy!
  end

  test "a reset token can only be consumed by one concurrent request" do
    token = @user.password_reset_token
    barrier = Concurrent::CyclicBarrier.new(2)
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |event|
      if Thread.current[:concurrent_reset] && event.payload[:sql].include?('FROM "users"')
        Thread.current[:concurrent_reset] = false
        raise Timeout::Error unless barrier.wait(5)
      end
    end
    threads = 2.times.map do |index|
      Thread.new do # rubocop:disable ThreadSafety/NewThread -- Real requests must overlap to exercise row locks.
        Rails.application.executor.wrap do
          Thread.current[:concurrent_reset] = true
          browser = ActionDispatch::Integration::Session.new(Rails.application)
          password = "new-password-2026-#{index}"
          browser.put("/passwords/#{token}", params: { password: password, password_confirmation: password })
          [ browser.response.status, browser.response.location ]
        end
      end
    end
    results = join_threads(threads)
    assert_equal 1, results.count { |_, location| URI(location).path == "/session/new" }
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    threads&.each { |thread| thread.kill if thread.alive? }
    threads&.each(&:join)
  end

  test "sign in cannot use a digest loaded before password reset" do
    loaded = Concurrent::Event.new
    reset = Concurrent::Event.new
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |event|
      if Thread.current[:concurrent_signin] && event.payload[:sql].include?('FROM "users"')
        Thread.current[:concurrent_signin] = false
        loaded.set
        raise Timeout::Error unless reset.wait(5)
      end
    end
    thread = Thread.new do # rubocop:disable ThreadSafety/NewThread -- Real requests must overlap to exercise row locks.
      Rails.application.executor.wrap do
        Thread.current[:concurrent_signin] = true
        browser = ActionDispatch::Integration::Session.new(Rails.application)
        browser.post("/session", params: { email_address: @user.email_address, password: "old-password-2026" })
        status = browser.response.status
        browser.get("/account")
        [ status, browser.response.status ]
      end
    end
    assert loaded.wait(5)
    User.reset_password(token: @user.password_reset_token, password: "replacement-password-2026", password_confirmation: "replacement-password-2026")
    reset.set
    result = join_threads([ thread ]).first
    assert_equal 422, result.first
    assert_equal 303, result.last
    assert_empty @user.sessions
  ensure
    reset&.set
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
    thread&.kill if thread&.alive?
    thread&.join
  end

  private

  def join_threads(threads)
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
      threads.map do |thread|
        raise Timeout::Error unless thread.join(10)
        thread.value
      end
    end
  end
end
