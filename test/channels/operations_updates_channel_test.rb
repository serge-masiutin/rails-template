require "test_helper"

class OperationsUpdatesChannelTest < ActionCable::Channel::TestCase
  tests OperationsUpdatesChannel

  test "administrator receives shared updates and personal access revocation" do
    stub_connection current_user: users(:admin)
    subscribe signed_stream_name: Turbo::StreamsChannel.signed_stream_name(Operations::Updates::STREAM)
    assert subscription.confirmed?
    assert_has_stream Operations::Updates::STREAM
    assert_has_stream Operations::Updates.access_stream(users(:admin).id)
  end

  test "regular users cannot subscribe even with a valid stream signature" do
    stub_connection current_user: users(:one)
    subscribe signed_stream_name: Turbo::StreamsChannel.signed_stream_name(Operations::Updates::STREAM)
    assert subscription.rejected?
    assert_no_streams
  end

  test "administrator cannot substitute another stream name" do
    stub_connection current_user: users(:admin)
    subscribe signed_stream_name: Turbo::StreamsChannel.signed_stream_name("foreign")
    assert subscription.rejected?
    assert_no_streams
  end
end
