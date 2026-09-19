require "test_helper"

class RealtimeTest < ActionDispatch::IntegrationTest
  test "RPC requires the separate server secret" do
    post "/_anycable/connect", params: "{}", headers: { "Content-Type" => "application/json" }
    assert_response :unauthorized
  end

  test "private subscription appears only after sign-in" do
    get new_session_path
    assert_select "turbo-cable-stream-source", count: 0
    sign_in_as users(:one)
    get root_path
    assert_select "turbo-cable-stream-source[channel=UserUpdatesChannel]", count: 1
    assert_select "meta[name=realtime-session][data-turbo-track=reload]"
  end

  test "sign-out revokes the session and enqueues WebSocket disconnect" do
    sign_in_as users(:one)
    session_id = users(:one).sessions.last.id
    assert_enqueued_with(job: DisconnectSessionsJob, args: [ [ session_id ] ]) { delete session_path }
    assert_not Session.exists?(session_id)
  end
end
