require "test_helper"

class UserUpdatesChannelTest < ActionCable::Channel::TestCase
  tests UserUpdatesChannel

  setup { stub_connection current_user: users(:one) }

  test "владелец получает собственный поток" do
    subscribe signed_stream_name: token(users(:one))
    assert subscription.confirmed?
    assert_has_stream users(:one).updates_stream_name
  end

  test "даже подписанный чужой поток запрещён" do
    subscribe signed_stream_name: token(users(:two))
    assert subscription.rejected?
    assert_no_streams
  end

  test "подделка подписи запрещена" do
    subscribe signed_stream_name: "invalid"
    assert subscription.rejected?
    assert_no_streams
  end

  private

  def token(user)
    Turbo::StreamsChannel.signed_stream_name(user.updates_stream_name)
  end
end
