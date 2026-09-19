class UserUpdatesChannel < Turbo::StreamsChannel
  def subscribed
    expected = connection.current_user.updates_stream_name
    if verified_stream_name_from_params == expected
      stream_from expected
    else
      reject
    end
  end
end
