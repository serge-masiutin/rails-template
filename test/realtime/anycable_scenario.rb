require "application_system_test_case"

Capybara.server_host = "0.0.0.0"
Capybara.server_port = 3100
Capybara.app_host = "http://127.0.0.1:3100"

class AnyCableScenario < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  self.use_transactional_tests = false

  setup do
    # Rails TestHelper подменяет pubsub; restart возвращает адаптер из cable.yml.
    ActionCable.server.restart
    assert_instance_of ActionCable::SubscriptionAdapter::AnyCable, ActionCable.server.pubsub
  end

  test "реальный Go сервер доставляет Turbo Stream, восстанавливает пропуск и отзывает сессию" do
    visit root_path
    fill_in "Email", with: users(:one).email_address
    fill_in "Пароль", with: "password"
    click_button "Войти"
    assert_selector "turbo-cable-stream-source[connected]", visible: :all

    publish_notice("Первое обновление")
    assert_text "Первое обновление"

    page.evaluate_async_script("const done = arguments[0]; import('cable').then(({ default: cable }) => { window.realtimeProbe = cable; done(true) })")
    page.execute_script("window.realtimeProbe.disconnect()")
    assert_no_selector "turbo-cable-stream-source[connected]", visible: :all
    publish_notice("Обновление во время обрыва")
    page.execute_script("window.realtimeProbe.connect()")
    assert_text "Обновление во время обрыва"

    # Повторная подписка на чужой, корректно подписанный stream должна быть отвергнута.
    other_token = Turbo::StreamsChannel.signed_stream_name(users(:two).updates_stream_name)
    page.execute_script(<<~JS, other_token)
      const source = document.createElement('turbo-cable-stream-source')
      source.setAttribute('channel', 'UserUpdatesChannel')
      source.setAttribute('signed-stream-name', arguments[0])
      source.id = 'foreign-stream'
      document.body.appendChild(source)
      source.channel.on('close', () => source.setAttribute('rejected', ''))
    JS
    assert_selector "#foreign-stream[rejected]", visible: :all

    page.execute_script("document.body.dataset.beforeHistoryLoss = ''; window.realtimeProbe.disconnect()")
    assert_no_selector "turbo-cable-stream-source[connected]", visible: :all
    3.times { |index| publish_notice("Вытеснение истории #{index}") }
    page.execute_script("window.realtimeProbe.connect()")
    assert_no_selector "body[data-before-history-loss]"
    assert_selector "turbo-cable-stream-source[connected]", visible: :all

    perform_enqueued_jobs(only: DisconnectSessionsJob) { Session.revoke_all!(users(:one).sessions) }
    assert_no_selector "turbo-cable-stream-source[connected]", visible: :all
    visit account_path
    assert_text "Войти в StarterApp"
  end

  private

  def publish_notice(message)
    Turbo::StreamsChannel.broadcast_update_to(users(:one).updates_stream_name,
      target: "flash", html: ApplicationController.render(Ui::NoticeComponent.new(message: message, variant: :notice), layout: false))
  end
end
