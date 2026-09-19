require "test_helper"

class ConnectionTest < ActionCable::Connection::TestCase
  tests ApplicationCable::Connection

  test "подписанная cookie определяет пользователя" do
    session = users(:one).sessions.create!
    cookies.signed[:session_id] = session.id
    connect
    assert_equal session.id, connection.session_id
    assert_equal users(:one), connection.current_user
  end

  test "гость и поддельная cookie не получают соединение" do
    assert_reject_connection { connect }
    cookies[:session_id] = "1"
    assert_reject_connection { connect }
  end

  test "удалённая сессия больше не действует" do
    session = users(:one).sessions.create!
    cookies.signed[:session_id] = session.id
    session.destroy!
    assert_reject_connection { connect }
  end
end
