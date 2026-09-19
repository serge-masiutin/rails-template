require "test_helper"

class ConnectionTest < ActionCable::Connection::TestCase
  tests ApplicationCable::Connection

  test "signed cookie identifies the user" do
    session = users(:one).sessions.create!
    cookies.signed[:session_id] = session.id
    connect
    assert_equal session.id, connection.session_id
    assert_equal users(:one), connection.current_user
  end

  test "guest and forged cookie cannot connect" do
    assert_reject_connection { connect }
    cookies[:session_id] = "1"
    assert_reject_connection { connect }
  end

  test "deleted session is no longer valid" do
    session = users(:one).sessions.create!
    cookies.signed[:session_id] = session.id
    session.destroy!
    assert_reject_connection { connect }
  end
end
